module Page.Home exposing (Todo, initialTodo, view)

import Html exposing (Html, table, tbody, td, text, th, thead, tr)


type alias Todo =
    { title : String
    , content : Maybe String
    , completed : Bool
    , id : Maybe Int
    }


initialTodo =
    Todo "" (Just "") False Nothing


view : List Todo -> Html msg
view todos =
    table []
        [ thead []
            [ tr []
                [ th [] [ text "Title" ]
                , th [] [ text "Content" ]
                , th [] [ text "Completed?" ]
                ]
            ]
        , tbody [] (tableBody todos)
        ]


tableBody : List Todo -> List (Html msg)
tableBody todos =
    List.map
        (\todo ->
            tr []
                [ td [] [ text todo.title ]
                , td [] [ text (Maybe.withDefault "-" todo.content) ]
                , td []
                    [ text
                        (if todo.completed then
                            "✓"

                         else
                            "˟"
                        )
                    ]
                ]
        )
        todos
