import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam_community/maths
import gleeunit/should
import simplifile

const filename = "day8.txt"

const connections_allowance = 1000

type JunctionBox {
  JunctionBox(x: Int, y: Int, z: Int)
}

type WeighedConnection {
  WeighedConnection(box1: JunctionBox, box2: JunctionBox, distance: Float)
}

type Circuit {
  Circuit(boxes: Set(JunctionBox))
}

type Graph =
  Dict(JunctionBox, Set(JunctionBox))

pub fn pb1() -> Int {
  let junction_boxes = get_junction_boxes(filename)
  let limitless_connections =
    list.combination_pairs(junction_boxes)
    |> list.map(fn(boxes) {
      let #(box1, box2) = boxes
      compute_distance(box1, box2)
    })
    |> list.sort(fn(weighed_connection1, weighed_connection2) {
      float.compare(weighed_connection1.distance, weighed_connection2.distance)
    })
  io.println("finished computing all possible connections")
  let connections =
    limitless_connections
    |> list.take(connections_allowance)

  let graph = connections_to_graph(connections)
  let circuits = graph_to_circuits(graph)
  //   list.each(circuits, display_circuit)
  list.map(circuits, fn(circuit) { set.size(circuit.boxes) })
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, fn(acc, circuit_size) { circuit_size * acc })
  //   list.fold(circuits, 0, fn(acc, circuit) { acc + list.length(circuit.boxes) })
}

pub fn pb2() -> Int {
  let junction_boxes = get_junction_boxes(filename)
  let limitless_connections =
    list.combination_pairs(junction_boxes)
    |> list.map(fn(boxes) {
      let #(box1, box2) = boxes
      compute_distance(box1, box2)
    })
    |> list.sort(fn(weighed_connection1, weighed_connection2) {
      float.compare(weighed_connection1.distance, weighed_connection2.distance)
    })

  // Take from limitless_connections one at a time until there is only a single circuit
  // The result is multiplying the X values for the boxes of the last connection made

  // -> fold_until
  // -> last connection should be returned in the accumulator

  let #(all_circuits_should_just_be_one, _remaining_boxes, last_connection) =
    list.fold_until(
      limitless_connections,
      #(
        [],
        junction_boxes |> set.from_list,
        limitless_connections |> list.first |> should.be_ok,
      ),
      fn(acc, weighed_connection) {
        let #(current_circuits, remaining_boxes, _last_connection) = acc

        let new_remaining_boxes =
          set.difference(
            remaining_boxes,
            [weighed_connection.box1, weighed_connection.box2] |> set.from_list,
          )

        let new_circuits =
          merge_circuits_with_new_connection(
            current_circuits,
            weighed_connection,
          )

        let new_acc = #(new_circuits, new_remaining_boxes, weighed_connection)
        case new_circuits, set.size(new_remaining_boxes) {
          [_one], 0 -> list.Stop(new_acc)
          _, _ -> list.Continue(new_acc)
        }
      },
    )

  last_connection.box1.x * last_connection.box2.x
}

fn connection_to_circuit(conn: WeighedConnection) -> Circuit {
  Circuit([conn.box1, conn.box2] |> set.from_list)
}

fn merge_circuits(circuit1: Circuit, circuit2: Circuit) -> Result(Circuit, Nil) {
  let c1_set = circuit1.boxes
  let c2_set = circuit2.boxes
  case set.is_disjoint(c1_set, c2_set) {
    False -> set.union(c1_set, c2_set) |> Circuit |> Ok
    True -> Error(Nil)
  }
}

fn merge_circuits_with_new_connection(
  circuits: List(Circuit),
  new_connection: WeighedConnection,
) -> List(Circuit) {
  let new_circuit = new_connection |> connection_to_circuit

  let #(new_circuit, existing_circuits) =
    list.fold(
      circuits,
      #(new_circuit, []),
      fn(acc, next_circuit_to_check_against) {
        let #(new_circuit, merged_circuits) = acc

        case merge_circuits(new_circuit, next_circuit_to_check_against) {
          Error(_) -> #(new_circuit, [
            next_circuit_to_check_against,
            ..merged_circuits
          ])
          Ok(new_new_circuit) -> #(new_new_circuit, merged_circuits)
        }
      },
    )

  [new_circuit, ..existing_circuits]
  //   let conn_boxes = [new_connection.box1, new_connection.box2] |> set.from_list
  //   let #(new_circuit, remaining_circuits) =
  //     list.fold(circuits, #(Circuit(conn_boxes), []), fn(acc, circuit) {
  //       let #(current_new_circuit, other_circuits) = acc
  //       let circuit_boxes = circuit.boxes
  //       case set.is_disjoint(conn_boxes, circuit_boxes) {
  //         True -> #(current_new_circuit, [circuit, ..other_circuits])
  //         False -> #(
  //           Circuit(set.union(conn_boxes, circuit_boxes)),
  //           other_circuits,
  //         )
  //       }
  //     })

  //   [new_circuit, ..remaining_circuits]
}

fn graph_to_circuits(graph: Graph) -> List(Circuit) {
  dict.fold(graph, [], fn(circuits, key, val) {
    let interconnected = set.insert(val, key)
    let #(new_circuit, rest) =
      list.fold(
        circuits,
        #(Circuit(interconnected), []),
        fn(acc: #(Circuit, List(Circuit)), next_circuit: Circuit) {
          let #(circuit_around_box, merged_circuits) = acc
          case set.is_disjoint(interconnected, next_circuit.boxes) {
            True -> #(circuit_around_box, [next_circuit, ..merged_circuits])
            False -> #(
              Circuit(set.union(circuit_around_box.boxes, next_circuit.boxes)),
              merged_circuits,
            )
          }
        },
      )
    [new_circuit, ..rest]
  })
}

fn display_circuit(circuit: Circuit) -> Nil {
  {
    "["
    <> set.fold(circuit.boxes, "", fn(acc, box) {
      acc <> int.to_string(box.x) <> " ; "
    })
    <> "]"
  }
  |> io.println
}

// fn dfs(
//   graph: Graph,
//   start: JunctionBox,
//   stack: Set(JunctionBox),
//   visited: Set(JunctionBox),
// ) -> Circuit {
//   let new_visited = set.insert(visited, start)
//   let assert Ok(neighbors) = dict.get(graph, start)
//   let new_stack = set.union(stack, neighbors) |> set.difference(new_visited)
//   case set.is_empty {

//   }

//   todo
// }

fn connections_to_graph(connections: List(WeighedConnection)) -> Graph {
  list.fold(connections, dict.new(), fn(acc, next_connection) {
    dict.upsert(acc, next_connection.box1, fn(found_connections_for_box) {
      case found_connections_for_box {
        option.None -> [next_connection.box2] |> set.from_list
        option.Some(connected_to) ->
          set.insert(connected_to, next_connection.box2)
      }
    })
    dict.upsert(acc, next_connection.box2, fn(found_connections_for_box) {
      case found_connections_for_box {
        option.None -> [next_connection.box1] |> set.from_list
        option.Some(connected_to) ->
          set.insert(connected_to, next_connection.box1)
      }
    })
  })
}

fn display_list(from: List(a)) -> String {
  list.fold(from, "", fn(acc, item) { acc <> item |> string.inspect <> "\n" })
}

fn get_junction_boxes(filename: String) -> List(JunctionBox) {
  simplifile.read(filename)
  |> should.be_ok
  |> string.split("\n")
  |> list.map(line_to_junction_box)
}

fn line_to_junction_box(line: String) -> JunctionBox {
  let assert Ok([x, y, z]) =
    string.split(line, ",") |> list.map(int.parse) |> result.all
  JunctionBox(x, y, z)
}

fn compute_distance(box1: JunctionBox, box2: JunctionBox) -> WeighedConnection {
  let distance =
    maths.euclidean_distance([
      #(box1.x |> int.to_float, box2.x |> int.to_float),
      #(box1.y |> int.to_float, box2.y |> int.to_float),
      #(box1.z |> int.to_float, box2.z |> int.to_float),
    ])
    |> should.be_ok
  WeighedConnection(box1, box2, distance)
}
