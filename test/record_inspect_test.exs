defmodule RecordInspectTest do
  use ExUnit.Case, async: true
  import Record

  defrecord :person, [:name, :email]
  RecordInspect.def(:person, [:name, :email])

  test "inspect with matching record" do
    assert inspect(person(name: "Alice", email: "alice@example.com")) ==
             ~s|#person([name: "Alice", email: "alice@example.com"])|
  end

  test "inspect with no match" do
    assert inspect({:person, "foo"}) == ~s|{:person, "foo"}|
  end
end
