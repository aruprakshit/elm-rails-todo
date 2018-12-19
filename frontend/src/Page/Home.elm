module Page.Home exposing (Todo, initialTodo, view)

import Html exposing (Html, a, caption, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, href)
import Utils.Todo exposing (idToString)


type alias Todo =
    { title : String
    , content : Maybe String
    , completed : Bool
    , id : Maybe Int
    }


initialTodo =
    Todo "" Nothing False Nothing


view : List Todo -> Html msg
view todos =
    div []
        [ table []
            [ caption [] [ text "All Todos" ]
            , thead []
                [ tr []
                    [ th [ class "col" ] [ text "Title" ]
                    , th [ class "col" ] [ text "Content" ]
                    , th [ class "col" ] [ text "Completed?" ]
                    , th [ class "col" ] []
                    ]
                ]
            , tbody [] (tableBody todos)
            ]
        , a [ href "todos/new" ] [ text "Create Todo" ]
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
                , td []
                    [ a [ href ("todos/" ++ idToString todo.id) ] [ text "Show" ] ]
                ]
        )
        todos
