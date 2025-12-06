import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should
import simplifile

const filename = "day6.txt"

type MathProblem {
  MathProblem(numbers: List(Int), func: fn(Int, Int) -> Int)
}

type Operation {
  Multiply
  Add
}

pub fn pb1() -> Int {
  let problems =
    simplifile.read(filename)
    |> should.be_ok
    |> pb1_sheet_to_problems

  let solutions = list.map(problems, compute_math_problem)

  list.reduce(solutions, int.add) |> should.be_ok
}

pub fn pb2() -> Int {
  let problems =
    simplifile.read(filename)
    |> should.be_ok
    |> pb2_sheet_to_problems

  let solutions = list.map(problems, compute_math_problem)

  list.reduce(solutions, int.add) |> should.be_ok
}

fn pb2_sheet_to_problems(from: String) -> List(MathProblem) {
  let rows = string.split(from, "\n")
  let assert [operation_row_string, ..numbers_rows] = list.reverse(rows)
  let operations_row =
    parse_row(operation_row_string, fn(grapheme) {
      case grapheme {
        "*" -> Multiply
        "+" -> Add
        _ -> panic as { "Found unknown operation: " <> grapheme }
      }
    })
  let cephalopod_sheet = list.map(numbers_rows, string.to_graphemes)

  list.transpose(cephalopod_sheet)
  |> list.map(fn(number_row) {
    list.filter(number_row, fn(char) { char != " " })
    |> list.reverse
    |> string.concat
  })
  |> list.map(int.parse)
  |> list.chunk(result.is_error)
  |> list.sized_chunk(2)
  |> list.map(fn(problem) {
    case problem {
      [numbers, [Error(Nil)]] -> numbers
      [numbers] -> numbers
      _ -> panic as { "????? " <> string.inspect(problem) }
    }
    |> list.map(should.be_ok)
  })
  |> list.strict_zip(operations_row)
  |> should.be_ok
  |> list.map(fn(problem_raw) {
    let #(numbers, op) = problem_raw
    column_into_problem(numbers, op)
  })
}

fn pb1_sheet_to_problems(from: String) -> List(MathProblem) {
  let assert Ok(#(n1_row_string, rest)) = string.split_once(from, "\n")
  let assert Ok(#(n2_row_string, rest)) = string.split_once(rest, "\n")
  let assert Ok(#(n3_row_string, rest)) = string.split_once(rest, "\n")
  let assert Ok(#(n4_row_string, operation_row_string)) =
    string.split_once(rest, "\n")

  let n1_row =
    parse_row(n1_row_string, fn(element) { int.parse(element) |> should.be_ok })
  let n2_row =
    parse_row(n2_row_string, fn(element) { int.parse(element) |> should.be_ok })
  let n3_row =
    parse_row(n3_row_string, fn(element) { int.parse(element) |> should.be_ok })
  let n4_row =
    parse_row(n4_row_string, fn(element) { int.parse(element) |> should.be_ok })
  let operation_row =
    parse_row(operation_row_string, fn(element) {
      case element {
        "+" -> Add
        "*" -> Multiply
        _ -> panic as { "unknown operation: " <> element }
      }
    })

  rows_to_problems([], n1_row, n2_row, n3_row, n4_row, operation_row)
}

fn compute_math_problem(from: MathProblem) -> Int {
  list.reduce(from.numbers, from.func) |> should.be_ok
}

fn rows_to_problems(
  acc: List(MathProblem),
  n1_row: List(Int),
  n2_row: List(Int),
  n3_row: List(Int),
  n4_row: List(Int),
  ops_row: List(Operation),
) -> List(MathProblem) {
  case n1_row, n2_row, n3_row, n4_row, ops_row {
    [], [], [], [], [] -> acc
    [n1, ..n1_rest],
      [n2, ..n2_rest],
      [n3, ..n3_rest],
      [n4, ..n4_rest],
      [op, ..ops_rest]
    ->
      list.prepend(acc, column_into_problem([n1, n2, n3, n4], op))
      |> rows_to_problems(n1_rest, n2_rest, n3_rest, n4_rest, ops_rest)

    _, _, _, _, _ -> panic as "lists not same lengths"
  }
}

fn column_into_problem(numbers: List(Int), op: Operation) -> MathProblem {
  case op {
    Add -> MathProblem(numbers, int.add)
    Multiply -> MathProblem(numbers, int.multiply)
  }
}

fn parse_row(row: String, mapping: fn(String) -> a) -> List(a) {
  string.split(row, " ")
  |> list.filter_map(fn(element) {
    case element == "" {
      True -> Error(Nil)
      False -> Ok(mapping(element))
    }
  })
}
