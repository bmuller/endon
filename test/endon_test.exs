defmodule EndonTest do
  use ExUnit.Case
  alias Endon.{RecordNotFoundError, ValidationError}

  describe "building queries via scope" do
    import UserHelpers
    import Ecto.Query, only: [from: 2]

    test "should return the correct query" do
      result = UserSingle.scope(id: 1) |> i()
      assert result == "from u0 in UserSingle, where: u0.id == ^1"
    end

    test "should build on a query successfully" do
      query = from(x in UserSingle, where: x.id == 1)
      result = query |> UserSingle.scope(org_id: 123) |> i()
      assert result == "from u0 in UserSingle, where: u0.id == 1, where: u0.org_id == ^123"
    end

    test "should build on a query successfully and run in a where" do
      query = from(x in UserSingle, where: x.id == 1)
      result = query |> UserSingle.scope(org_id: 123) |> UserSingle.first()

      assert result ==
               "from u0 in UserSingle, where: u0.id == 1, where: u0.org_id == ^123, limit: ^1"
    end
  end

  describe "aggregate functions should work" do
    test "when using empty count" do
      assert UserSingle.count() == "from u0 in UserSingle, select: count()"
    end
  end

  describe "querying records should work" do
    test "when using where" do
      assert UserSingle.where(id: 1) == ["from u0 in UserSingle, where: u0.id == ^1"]
    end

    test "when using where with limit" do
      assert UserSingle.where(id: 1, limit: 2) == [
               "from u0 in UserSingle, where: u0.id == ^1, where: u0.limit == ^2"
             ]
    end

    test "when using stream_where" do
      assert Enum.to_list(UserNone.stream_where()) == []
    end

    test "when using find" do
      assert UserSingle.find(1) == "from u0 in UserSingle, where: u0.id in ^[1]"
      assert UserDouble.find([1, 2]) == ["from u0 in UserDouble, where: u0.id in ^[1, 2]", nil]

      assert_raise(RecordNotFoundError, fn ->
        UserSingle.find([1, 2])
      end)

      assert_raise(RecordNotFoundError, fn ->
        UserNone.find(1)
      end)
    end

    test "when using fetch" do
      assert UserSingle.fetch(1) == {:ok, "from u0 in UserSingle, where: u0.id in ^[1]"}

      assert UserDouble.fetch([1, 2]) ==
               {:ok, ["from u0 in UserDouble, where: u0.id in ^[1, 2]", nil]}

      assert UserSingle.fetch([1, 2]) == :error
      assert UserNone.fetch(1) == :error
    end

    test "when using exists" do
      refute UserNone.exists?(one: 1)
      assert UserSingle.exists?(one: 1)
    end
  end

  describe "updating records should work" do
    test "when calling update" do
      {:ok, us} = UserOK.update(%UserSingle{}, id: 1)
      assert us.changes == %{id: 1}

      {:error, us} = UserError.update(%UserSingle{}, id: 1)
      assert us.changes == %{id: 1}
    end

    test "when calling update!" do
      us = UserOK.update!(%UserSingle{}, id: 1)
      assert us.changes == %{id: 1}

      assert_raise(ValidationError, fn ->
        UserError.update!(%UserSingle{}, id: 1)
      end)
    end
  end

  describe "creating records should work" do
    test "when calling create" do
      {:ok, us} = UserOK.create(id: 1)
      assert us.changes == %{id: 1}

      {:error, us} = UserError.create(id: 1)
      assert us.changes == %{id: 1}
    end

    test "when calling create!" do
      us = UserOK.create!(id: 1)
      assert us.changes == %{id: 1}

      assert_raise(ValidationError, fn ->
        UserError.create!(id: 1)
      end)
    end
  end

  describe "deleting records should work" do
    test "when calling delete" do
      {:ok, us} = UserOK.delete(%UserOK{id: 1})
      assert us == %UserOK{id: 1}

      {:error, us} = UserError.delete(%UserOK{id: 1})
      assert us.input == %UserOK{id: 1}
    end

    test "when calling delete!" do
      us = UserOK.delete!(%UserOK{id: 1})
      assert us == %UserOK{id: 1}

      assert_raise(ValidationError, "Could not delete Elixir.UserError: \"sorry\"", fn ->
        UserError.delete!(%UserOK{id: 1})
      end)
    end
  end
end
