module Page.Home exposing (Msg(..), update, view)

import Config exposing (AuthState(..), backendDomain)
import Decoders.Todos exposing (todosListDecoder)
import Entities.Todo as Todo
import Html exposing (Html, a, button, caption, div, option, select, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, href, scope, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Url.Builder as UB
import Utils.Todo exposing (idToString)


type Msg
    = NoOp
    | Delete String
    | Deleted String (Result Http.Error ())
    | ChangeFilter String
    | SearchResults (Result Http.Error Model)


type alias Model =
    List Todo.Model


update : Config.Model -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangeFilter filterValue ->
            ( model, searchTodos config filterValue )

        SearchResults response ->
            case response of
                Ok todos ->
                    ( todos, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        Delete todoId ->
            ( model, deleteTodo config todoId )

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


tableView : Model -> Html Msg
tableView model =
    div [ class "row" ]
        [ div [ class "col-12" ]
            [ table [ class "table table-striped" ]
                [ thead []
                    [ tr []
                        [ th [ scope "col" ] [ text "Title" ]
                        , th [ scope "col" ] [ text "Content" ]
                        , th [ scope "col" ] [ text "Completed?" ]
                        , th [ scope "col" ] [ tableFilter ]
                        ]
                    ]
                , tbody [] (tableBody model)
                ]
            ]
        ]


view : Model -> List (Html Msg)
view model =
    [ div [ class "card mb-4" ]
        [ div [ class "card-body" ]
            [ a [ href "todos/new", class "btn btn-primary" ] [ text "Create Todo" ]
            ]
        ]
    , tableView model
    ]


tableFilter : Html Msg
tableFilter =
    select [ onInput ChangeFilter ]
        [ option [ value "1" ] [ text "All" ]
        , option [ value "2" ] [ text "Completed" ]
        , option [ value "3" ] [ text "Not Completed" ]
        ]


tableBody : Model -> List (Html Msg)
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
                    [ a [ href ("todos/" ++ idToString todo.id), class "btn btn-sm btn-primary" ] [ text "Show" ]
                    , button [ type_ "button", onClick (Delete (idToString todo.id)), class "btn btn-sm btn-danger" ] [ text "Delete" ]
                    ]
                ]
        )
        todos


deleteTodo : Config.Model -> String -> Cmd Msg
deleteTodo config todoId =
    let
        authToken =
            case config.token of
                Authenticated value ->
                    value

                NotAuthenticated ->
                    ""
    in
    Http.request
        { method = "DELETE"
        , headers =
            [ Http.header "Authorization" authToken
            ]
        , url = backendDomain ++ UB.absolute [ "todos", todoId ] []
        , body = Http.emptyBody
        , expect = Http.expectWhatever (Deleted todoId)
        , timeout = Nothing
        , tracker = Nothing
        }


searchTodos : Config.Model -> String -> Cmd Msg
searchTodos config filterValue =
    let
        authToken =
            case config.token of
                Authenticated value ->
                    value

                NotAuthenticated ->
                    ""
    in
    Http.request
        { method = "POST"
        , headers =
            [ Http.header "Authorization" authToken
            ]
        , url =
            backendDomain
                ++ UB.absolute [ "todos", "search" ] [ UB.string "q" filterValue ]
        , body = Http.emptyBody
        , expect = Http.expectJson SearchResults todosListDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
