module Utils.Todo exposing (idToString)


idToString : Maybe Int -> String
idToString number =
    number
        |> Maybe.map String.fromInt
        |> Maybe.withDefault ""
