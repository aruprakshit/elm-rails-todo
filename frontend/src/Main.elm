module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Decoders.Todos exposing (todoDecoder, todosListDecoder)
import Html exposing (Html, div, h1, text)
import Http
import Json.Decode as JD
import Navigation exposing (Route(..), toRoute)
import Page.Home as HomePage exposing (Todo, initialTodo)
import Page.Todos.New as NewTodoPage
import Page.Todos.Show as ShowTodoPage
import Url exposing (Url)
import Utils.Todo exposing (idToString)



-- MODEL


type alias Model =
    { key : Nav.Key
    , state : State
    }


type State
    = NewTodo Todo
    | EditTodo Todo
    | Home (List Todo)
    | ShowTodo (Maybe Todo)


initialModel : Nav.Key -> Model
initialModel key =
    Model key (Home [])



-- UPDATE


type Msg
    = ChangedUrl Url
    | ActivatedLink Browser.UrlRequest
    | GotTodos (Result Http.Error (List Todo))
    | NewTodoPageMsg NewTodoPage.Msg
    | GotTodo (Result Http.Error Todo)
    | HomePageMsg HomePage.Msg


getCurrentPageData : Model -> Url -> ( Model, Cmd Msg )
getCurrentPageData model url =
    case toRoute <| Url.toString url of
        Index ->
            ( model
            , fetchTodos
            )

        New ->
            ( { model | state = NewTodo initialTodo }
            , Cmd.none
            )

        Show todoId ->
            ( { model | state = ShowTodo Nothing }
            , fetchTodo todoId
            )

        Edit todoId ->
            ( model
            , Cmd.none
            )

        NotFound ->
            ( model
            , Cmd.none
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( HomePageMsg homeMsg, Home todos ) ->
            HomePage.update homeMsg todos
                |> Tuple.mapFirst (\newTodos -> { model | state = Home newTodos })
                |> Tuple.mapSecond (Cmd.map HomePageMsg)

        ( NewTodoPageMsg formControlMsg, NewTodo currentTodo ) ->
            NewTodoPage.update model.key formControlMsg currentTodo
                |> Tuple.mapFirst (\newTodo -> { model | state = NewTodo newTodo })
                |> Tuple.mapSecond (Cmd.map NewTodoPageMsg)

        ( ActivatedLink urlContainer, _ ) ->
            case urlContainer of
                Internal url ->
                    ( model, Nav.pushUrl model.key url.path )

                External path ->
                    ( model, Cmd.none )

        ( ChangedUrl url, _ ) ->
            getCurrentPageData model url

        ( GotTodo response, _ ) ->
            case response of
                Ok todo ->
                    ( { model | state = ShowTodo (Just todo) }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ( GotTodos response, _ ) ->
            case response of
                Ok todos ->
                    ( { model | state = Home todos }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )



-- INIT


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    getCurrentPageData (initialModel navKey) url



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


pageTitle : State -> String
pageTitle state =
    case state of
        Home _ ->
            "Home Page"

        NewTodo _ ->
            "Create a todo item"

        ShowTodo maybeTodo ->
            case maybeTodo of
                Just todo ->
                    todo.title

                Nothing ->
                    "Loading"

        _ ->
            ""


pageBody : Model -> Html Msg
pageBody { key, state } =
    let
        body =
            case state of
                Home todos ->
                    HomePage.view todos |> Html.map HomePageMsg

                NewTodo todo ->
                    NewTodoPage.view todo |> Html.map NewTodoPageMsg

                ShowTodo todo ->
                    ShowTodoPage.view todo

                _ ->
                    text "Not ready yet"
    in
    div []
        [ body
        ]


view : Model -> Document Msg
view model =
    { title = pageTitle model.state
    , body =
        [ pageBody model
        ]
    }



-- MAIN


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ActivatedLink
        }


fetchTodos : Cmd Msg
fetchTodos =
    Http.get
        { url = "http://localhost:3000/todos"
        , expect = Http.expectJson GotTodos todosListDecoder
        }


fetchTodo : Int -> Cmd Msg
fetchTodo todoId =
    Http.get
        { url = "http://localhost:3000/todos/" ++ String.fromInt todoId
        , expect = Http.expectJson GotTodo todoDecoder
        }
