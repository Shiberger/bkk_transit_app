import json
import heapq
from flask import Flask, jsonify, request

# --- Initialization ---
app = Flask(__name__)

# --- Data Loading ---
def load_data():
    with open('database.json', 'r', encoding='utf-8') as f:
        return json.load(f)

transit_data = load_data()
stations_map = {s['id']: s for s in transit_data['stations']}
lines_map = {l['line_id']: l for l in transit_data['lines']}

# --- Core Logic: Graph & Pathfinding ---

def build_graph():
    """Builds a graph representation from the transit data."""
    graph = {s_id: {} for s_id in stations_map}

    # Add edges for stations on the same line
    for line in lines_map.values():
        for i in range(len(line['station_ids']) - 1):
            u, v = line['station_ids'][i], line['station_ids'][i+1]
            weight = line['travel_time_between_stations']
            graph[u][v] = weight
            graph[v][u] = weight

    # Add edges for transfers
    for transfer in transit_data['transfers']:
        u, v = transfer['from_station_id'], transfer['to_station_id']
        weight = transfer['transfer_time']
        graph[u][v] = weight
        graph[v][u] = weight
        
    return graph

def dijkstra(graph, start_id, end_id):
    """Calculates the shortest path using Dijkstra's algorithm."""
    distances = {s_id: float('inf') for s_id in graph}
    distances[start_id] = 0
    predecessors = {s_id: None for s_id in graph}
    
    pq = [(0, start_id)]

    while pq:
        dist, current_id = heapq.heappop(pq)

        if dist > distances[current_id]:
            continue
        
        if current_id == end_id:
            break

        for neighbor_id, weight in graph[current_id].items():
            distance = dist + weight
            if distance < distances[neighbor_id]:
                distances[neighbor_id] = distance
                predecessors[neighbor_id] = current_id
                heapq.heappush(pq, (distance, neighbor_id))
    
    # Reconstruct path
    path = []
    current_id = end_id
    while current_id is not None:
        path.insert(0, current_id)
        current_id = predecessors[current_id]
        
    if path[0] == start_id:
        return distances[end_id], path
    else:
        return float('inf'), []

def get_line_for_segment(station1_id, station2_id):
    """Finds the line that connects two adjacent stations."""
    for line in lines_map.values():
        try:
            idx1 = line['station_ids'].index(station1_id)
            idx2 = line['station_ids'].index(station2_id)
            if abs(idx1 - idx2) == 1:
                return line
        except ValueError:
            continue
    return None

def format_path_as_steps(path, total_time):
    """Converts a list of station IDs into user-friendly steps."""
    if not path:
        return {"error": "No path found"}

    steps = []
    current_line = None
    segment_start_station_id = path[0]
    stops = 0

    for i in range(len(path) - 1):
        u, v = path[i], path[i+1]
        
        # Check if this is a transfer
        is_transfer = True
        line_of_segment = get_line_for_segment(u, v)
        if line_of_segment:
            is_transfer = False

        if is_transfer:
            # Finalize the previous 'board' step
            if current_line:
                steps.append({
                    "type": "board",
                    "line_name": current_line['line_name'],
                    "line_color": current_line['color'],
                    "start_station": stations_map[segment_start_station_id]['name'],
                    "end_station": stations_map[u]['name'],
                    "stops": stops,
                })
            # Add the 'transfer' step
            steps.append({
                "type": "transfer",
                "from_station": stations_map[u]['name'],
                "to_station": stations_map[v]['name'],
            })
            segment_start_station_id = v
            current_line = None
            stops = 0
        else:
            if not current_line or current_line['line_id'] != line_of_segment['line_id']:
                # Finalize previous step if line changes
                if current_line:
                    steps.append({
                        "type": "board",
                        "line_name": current_line['line_name'],
                        "line_color": current_line['color'],
                        "start_station": stations_map[segment_start_station_id]['name'],
                        "end_station": stations_map[u]['name'],
                        "stops": stops,
                    })
                # Start a new step
                segment_start_station_id = u
                current_line = line_of_segment
                stops = 1
            else:
                stops += 1

    # Add the final 'board' step
    if current_line:
        steps.append({
            "type": "board",
            "line_name": current_line['line_name'],
            "line_color": current_line['color'],
            "start_station": stations_map[segment_start_station_id]['name'],
            "end_station": stations_map[path[-1]]['name'],
            "stops": stops,
        })
    
    return {
        "total_time": total_time,
        "total_stations": len(path) -1,
        "steps": steps
    }


# --- API Endpoints ---

@app.route('/api/stations', methods=['GET'])
def get_stations():
    station_list = [{"id": s['id'], "name": s['name']} for s in stations_map.values()]
    return jsonify(sorted(station_list, key=lambda s: s['name']))

@app.route('/api/route', methods=['POST'])
def find_route_endpoint():
    data = request.get_json()
    if not data or 'start_station_id' not in data or 'end_station_id' not in data:
        return jsonify({"error": "Missing start or end station ID"}), 400

    start_id = data['start_station_id']
    end_id = data['end_station_id']

    if start_id == end_id:
        return jsonify({"error": "Start and destination cannot be the same"}), 400

    graph = build_graph()
    total_time, path = dijkstra(graph, start_id, end_id)

    if total_time == float('inf'):
        return jsonify({"error": f"No route found from {stations_map[start_id]['name']} to {stations_map[end_id]['name']}"}), 404
    
    response = format_path_as_steps(path, total_time)
    return jsonify(response)


# --- Main Execution ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)