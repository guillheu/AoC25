import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should
import simplifile

const filename = "day2.txt"

pub fn pb1() -> Int {
  solver(is_id_valid_pb1)
}

pub fn pb2() -> Int {
  solver(is_id_valid_pb2)
}

fn solver(check_fn: fn(Int) -> Bool) -> Int {
  simplifile.read(filename)
  |> should.be_ok
  |> string.split(",")
  |> list.map(fn(range) {
    io.println("\nNext range: " <> range)
    let #(start_string, end_string) =
      string.split_once(range, "-") |> should.be_ok
    let start = start_string |> int.parse |> should.be_ok
    let end = end_string |> int.parse |> should.be_ok
    io.println("IDs to check: " <> int.to_string(end - start + 1))
    io.println("")
    list.range(start, end)
    |> list.fold([], fn(acc, id) {
      case check_fn(id) {
        False -> [id, ..acc]
        True -> acc
      }
    })
    |> display_list
    |> list.reduce(int.add)
    |> result.unwrap(0)
  })
  |> list.reduce(int.add)
  |> should.be_ok
}

fn display_list(from: List(Int)) -> List(Int) {
  {
    "["
    <> {
      list.fold(from, "", fn(str, val) {
        str <> { val |> int.to_string } <> ","
      })
      |> string.drop_end(1)
    }
    <> "]"
  }
  |> io.println
  from
}

fn is_id_valid_pb1(id: Int) -> Bool {
  let id_string = int.to_string(id)
  let string_length = id_string |> string.length
  use <- bool.guard({ string_length % 2 } != 0, True)
  let substring_length = string_length / 2
  let substring = string.slice(id_string, 0, substring_length)
  { substring <> substring } != id_string
}

fn is_id_valid_pb2(id: Int) -> Bool {
  let id_string = int.to_string(id)
  let string_length = id_string |> string.length
  let max_prefix_length = string_length / 2
  list.range(1, max_prefix_length)
  |> list.all(fn(repeating_length) {
    use <- bool.guard(
      string_length % repeating_length != 0 || string_length == 1,
      True,
    )
    let repeat_to_check = string.slice(id_string, 0, repeating_length)
    let repeat_times = string_length / repeating_length
    let check_against = string.repeat(repeat_to_check, repeat_times)
    check_against != id_string
  })
}
