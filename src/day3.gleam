import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import gleeunit/should
import simplifile

const filename = "day3.txt"

pub fn pb1() -> Int {
  simplifile.read(filename)
  |> should.be_ok
  |> string.split("\n")
  |> list.map(pb1_figure_out_batteries_to_turn_on)
  |> list.fold(0, int.add)
}

fn pb1_figure_out_batteries_to_turn_on(line: String) -> Int {
  let batteries =
    string.to_graphemes(line)
    |> list.map(int.parse)
    |> result.all
    |> should.be_ok

  let first_is_largest =
    recurse_scan_bank_for_largest_first_digit(batteries, [])
  let second_digit_largest =
    list.drop(first_is_largest, 1)
    |> list.fold(0, int.max)
  let first_digit_largest = first_is_largest |> list.first |> should.be_ok

  10 * first_digit_largest + second_digit_largest
}

fn pb2_figure_out_batteries_to_turn_on(line: String) -> Int {
  let batteries =
    string.to_graphemes(line)
    |> list.map(int.parse)
    |> result.all
    |> should.be_ok

  // This should be done 11 times
  let first_is_largest =
    recurse_scan_bank_for_largest_first_digit(batteries, [])
  // hehehe

  let second_digit_largest =
    list.drop(first_is_largest, 1)
    |> list.fold(0, int.max)
  let first_digit_largest = first_is_largest |> list.first |> should.be_ok

  10 * first_digit_largest + second_digit_largest
}

fn recurse_scan_bank_for_largest_first_digit(
  remaining_batteries: List(Int),
  current_largest_and_following: List(Int),
) -> List(Int) {
  case remaining_batteries, current_largest_and_following {
    [_last], _ -> current_largest_and_following
    [_current, ..rest], [] ->
      recurse_scan_bank_for_largest_first_digit(rest, remaining_batteries)
    [current, ..rest], [acc_largest, ..] ->
      case current <= acc_largest {
        True ->
          recurse_scan_bank_for_largest_first_digit(
            rest,
            current_largest_and_following,
          )
        False ->
          recurse_scan_bank_for_largest_first_digit(rest, remaining_batteries)
      }
    [], _ -> panic as "We shouldnt get there"
  }
}
