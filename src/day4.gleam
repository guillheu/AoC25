import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should
import simplifile

const filename = "day4.txt"

type Tile {
  Empty
  Full
  Movable
}

type Map(a) =
  Dict(#(Int, Int), a)

pub fn pb1() -> Int {
  let map =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.map(text_to_tiles)
    |> list_of_lists_to_dict
  let #(_new_map, count) = count_rolls_and_remove(map)
  count
}

pub fn pb2() -> Int {
  let map =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.map(text_to_tiles)
    |> list_of_lists_to_dict

  keep_going_until_locked_map(map, 0)
}

fn keep_going_until_locked_map(map: Map(Tile), total_count: Int) -> Int {
  let #(new_map, new_count) = count_rolls_and_remove(map)
  case new_count {
    0 -> total_count
    _ -> keep_going_until_locked_map(new_map, total_count + new_count)
  }
}

fn count_rolls_and_remove(map: Map(Tile)) -> #(Map(Tile), Int) {
  let map_with_movables =
    map
    |> dict.map_values(fn(location, tile) {
      case
        tile,
        get_all_surrounding_locations(location)
        |> list.count(fn(location) {
          dict.get(map, location) |> result.unwrap(Empty) == Full
        })
        < 4
      {
        Empty, _ -> Empty
        Full, True -> Movable
        Full, False -> Full
        Movable, _ -> panic as "shouldnt be any movable tiles at this point"
      }
    })
  let count =
    map_with_movables
    |> dict.fold(0, fn(count, _location, tile) {
      case tile == Movable {
        False -> count
        True -> count + 1
      }
    })
  let map_with_movables_removed =
    map_with_movables
    |> dict.map_values(fn(_location, tile) {
      case tile {
        Movable -> Empty
        other -> other
      }
    })
  #(map_with_movables_removed, count)
}

fn text_to_tiles(line: String) -> List(Tile) {
  string.to_graphemes(line)
  |> list.map(fn(char) {
    case char {
      "@" -> Full
      "." -> Empty
      found -> panic as { "invalid input character: " <> found }
    }
  })
}

fn list_of_lists_to_dict(from: List(List(a))) -> Map(a) {
  list.index_fold(from, dict.new(), fn(acc, line, y_index) {
    list.index_fold(line, acc, fn(acc, item, x_index) {
      dict.insert(acc, #(x_index, y_index), item)
    })
  })
}

fn get_all_surrounding_locations(around: #(Int, Int)) -> List(#(Int, Int)) {
  let #(x, y) = around
  [
    #(x - 1, y - 1),
    #(x, y - 1),
    #(x + 1, y - 1),
    #(x + 1, y),
    #(x + 1, y + 1),
    #(x, y + 1),
    #(x - 1, y + 1),
    #(x - 1, y),
  ]
}
