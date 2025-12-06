import day1
import day2
import day3
import day4
import day5
import day6
import gleam/int
import gleam/io

pub fn main() -> Nil {
  let count = day6.pb2()
  io.println("The count is " <> count |> int.to_string)
}
