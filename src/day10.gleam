import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleeunit/should
import simplifile

const filename = "day10_sample.txt"

type Machine {
  Machine(lights: Set(Int), buttons: List(Set(Int)))
}

pub fn pb1() -> Int {
  let machines =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.map(line_to_machine)
    |> list.map(debug_machine)
  todo
}

fn march_lights_to_zero(
  available_buttons_to_press: List(Int),
  current_lights: Set(Int),
) -> Result(Int, Nil) {
  case current_lights |> set.size == 0 {
    True -> 1 |> Ok
    False -> {
      todo
    }
  }
}

fn debug_machine(machine: Machine) -> Machine {
  io.println("#### MACHINE ####")
  let lights_string =
    set.to_list(machine.lights)
    |> list.sort(int.compare)
    |> list.map(int.to_string)
    |> list.intersperse(", ")
    |> string.concat
  io.println("Lights: " <> lights_string)
  let buttons_string =
    list.map(machine.buttons, fn(button) {
      button
      |> set.to_list
      |> list.sort(int.compare)
      |> list.map(int.to_string)
      |> list.intersperse(",")
      |> string.concat
    })
    |> list.intersperse("\t")
    |> string.concat

  io.println("Buttons: " <> buttons_string)
  io.println("#################\n")

  machine
}

fn line_to_machine(line: String) -> Machine {
  let assert Ok(#(lights_string, rest)) = string.split_once(line, "]")
  let assert "[" <> lights_string = lights_string

  let assert Ok(#(buttons_string, joltages_string)) =
    string.split_once(rest, "{")
  let joltages_string =
    string.slice(joltages_string, 0, string.length(joltages_string) - 1)

  let lights =
    lights_string
    |> string.to_graphemes
    |> list.index_fold([], fn(acc, light_state, index) {
      case light_state {
        "." -> acc
        "#" -> [index, ..acc]
        _ -> panic as { "unknown light state: " <> light_state }
      }
    })
    |> set.from_list

  let buttons =
    string.split(buttons_string, " ")
    |> list.filter(fn(str) { str != "" })
    |> list.map(fn(button_string) {
      string.slice(button_string, 1, string.length(button_string) - 2)
      |> string.split(",")
      |> list.map(int.parse)
      |> result.all
      |> should.be_ok
      |> set.from_list
    })
    |> list.sort(fn(button_1, button_2) {
      int.compare(set.size(button_1), set.size(button_2))
    })

  Machine(lights, buttons)
}
