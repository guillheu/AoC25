import day1
import day2
import day3
import gleam/int
import gleam/io

pub fn main() -> Nil {
  let count = day3.pb1()
  io.println("The count is " <> count |> int.to_string)
}
