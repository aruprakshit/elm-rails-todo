module Page.Home exposing (Msg(..), Todo, initialTodo, update, view)

import Html exposing (Html, a, button, caption, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, href, type_)
import Html.Events exposing (onClick)
import Http
import Utils.Todo exposing (idToString)


type alias Todo =
    { title : String
    , content : Maybe String
    , completed : Bool
    , id : Maybe Int
    }


initialTodo =
    Todo "" Nothing False Nothing


type Msg
    = NoOp
    | Delete String
    | Deleted String (Result Http.Error ())


type alias Model =
    List Todo


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Delete todoId ->
            ( model, deleteTodo todoId )

        Deleted todoid response ->
            let
                id =
                    String.toInt todoid
            in
            case ( id, response ) of
                ( Just number, Ok _ ) ->
                    ( List.filter (\todo -> todo.id /= Just number) model, Cmd.none )

                ( _, _ ) ->
                    ( model, Cmd.none )


view : Model -> Html Msg
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


tableBody : List Todo -> List (Html Msg)
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
                    [ a [ href ("todos/" ++ idToString todo.id) ] [ text "Show" ]
                    , button [ type_ "button", onClick (Delete (idToString todo.id)) ] [ text "Delete" ]
                    ]
                ]
        )
        todos


deleteTodo : String -> Cmd Msg
deleteTodo todoId =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "http://localhost:3000/todos/" ++ todoId
        , body = Http.emptyBody
        , expect = Http.expectWhatever (Deleted todoId)
        , timeout = Nothing
        , tracker = Nothing
        }
