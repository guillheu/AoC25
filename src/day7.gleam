import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/set.{type Set}
import gleam/string
import gleeunit/should
import simplifile

const filename = "day7.txt"

type Beam =
  Int

type Splitter =
  Int

pub fn pb1() -> Int {
  let #(lines_with_splitters, rest) =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.partition(line_has_a_splitter)

  let splitters_arrays: List(List(Splitter)) =
    lines_with_splitters |> list.map(line_to_splitter_indices)
  let assert [first_line, ..rest] = rest

  let starting_beam: Beam =
    string.split(first_line, "S")
    |> list.first
    |> should.be_ok
    |> string.length

  let #(split_count, _final_beams) =
    list.fold(
      splitters_arrays,
      #(0, [starting_beam] |> set.from_list),
      fn(acc: #(Int, Set(Beam)), splitter_array) {
        list.fold(splitter_array, acc, fn(acc, splitter) {
          let #(count, beams) = acc
          case attempt_split_beam(beams, splitter) |> echo {
            Error(_) -> acc
            Ok(new_beams) -> #(count + 1, new_beams)
          }
        })
      },
    )

  split_count
}

pub fn pb2() -> Int {
  let #(lines_with_splitters, rest) =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.partition(line_has_a_splitter)

  let splitters_arrays: List(List(Splitter)) =
    lines_with_splitters |> list.map(line_to_splitter_indices)
  let assert [first_line, ..rest] = rest

  let starting_beam: Beam =
    string.split(first_line, "S")
    |> list.first
    |> should.be_ok
    |> string.length

  let final_beams =
    list.index_fold(
      splitters_arrays,
      [#(starting_beam, 1)] |> dict.from_list,
      fn(acc: Dict(Beam, Int), splitter_array, index) {
        io.println(
          "Computing new beams for line #"
          <> { { { index + 1 } * 2 } + 1 } |> int.to_string,
        )

        list.fold(splitter_array, acc, fn(beams, splitter) {
          attempt_split_beam_pb2(beams, splitter)
        })
      },
    )
    |> dict.fold(0, fn(count, _location, amount) { count + amount })
}

fn attempt_split_beam_pb2(
  beams: Dict(Beam, Int),
  splitter: Splitter,
) -> Dict(Beam, Int) {
  case dict.get(beams, splitter) {
    Error(_) -> beams
    Ok(amount) -> {
      dict.delete(beams, splitter)
      |> dict.upsert(splitter + 1, fn(optional_beams_amount) {
        option.unwrap(optional_beams_amount, 0) + amount
      })
      |> dict.upsert(splitter - 1, fn(optional_beams_amount) {
        option.unwrap(optional_beams_amount, 0) + amount
      })
    }
  }
}

fn line_to_splitter_indices(line: String) -> List(Splitter) {
  line
  |> string.to_graphemes
  |> list.index_fold([], fn(acc, char, index) {
    case char == "^" {
      False -> acc
      True -> [index, ..acc]
    }
  })
}

fn attempt_split_beam(
  beams: Set(Beam),
  splitter: Splitter,
) -> Result(Set(Beam), Nil) {
  case set.contains(beams, splitter) {
    False -> Error(Nil)
    True ->
      {
        let to_insert = set.from_list([splitter + 1, splitter - 1]) |> echo
        set.delete(beams, splitter) |> set.union(to_insert)
      }
      |> Ok
  }
}

fn line_has_a_splitter(line: String) -> Bool {
  "\\^" |> regexp.from_string |> should.be_ok |> regexp.check(line)
}
