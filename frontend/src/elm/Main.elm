module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Config exposing (AuthState(..), backendDomain)
import Decoders.Flags exposing (decodeFlags)
import Decoders.Todos exposing (todoDecoder, todosListDecoder)
import Entities.Signin as Signin
import Entities.Todo as Todo
import Html exposing (Html, a, button, div, h1, nav, text)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Navigation exposing (Route(..), toRoute)
import Page.Auth.Sessions as SessionsPage
import Page.Home as HomePage
import Page.NotFound as PageNotFound
import Page.Todos.Edit as EditTodoPage
import Page.Todos.New as NewTodoPage
import Page.Todos.Show as ShowTodoPage
import Ports exposing (clearAuthInfo)
import Url exposing (Url)
import Url.Builder as UB
import Utils.Todo exposing (idToString)



-- MODEL


type alias Model =
    { key : Nav.Key
    , state : State
    , authState : AuthState
    }


type State
    = NewTodo Todo.Model
    | EditTodo (Maybe Todo.Model)
    | Home (List Todo.Model)
    | ShowTodo (Maybe Todo.Model)
    | NoPageFound
    | Session Signin.Model


initialModel : Nav.Key -> AuthState -> Model
initialModel key authState =
    Model key (Session Signin.initialModel) authState



-- UPDATE


type Msg
    = ChangedUrl Url
    | ActivatedLink Browser.UrlRequest
    | GotTodos (Result Http.Error (List Todo.Model))
    | NewTodoPageMsg NewTodoPage.Msg
    | GotTodo (Result Http.Error Todo.Model)
    | HomePageMsg HomePage.Msg
    | EditTodoPageMsg EditTodoPage.Msg
    | SessionsPageMsg SessionsPage.Msg
    | LogOut


getCurrentPageData : Model -> Url -> ( Model, Cmd Msg )
getCurrentPageData model url =
    case toRoute <| Url.toString url of
        Index ->
            ( { model | state = Home [] }
            , fetchTodos model
            )

        New ->
            ( { model | state = NewTodo Todo.initialModel }
            , Cmd.none
            )

        Show todoId ->
            ( { model | state = ShowTodo Nothing }
            , fetchTodo model todoId
            )

        Edit todoId ->
            ( { model | state = EditTodo Nothing }
            , fetchTodo model todoId
            )

        Login ->
            ( model, Cmd.none )

        NotFound ->
            ( { model | state = NoPageFound }
            , Cmd.none
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        config =
            Config.Model model.authState model.key
    in
    case ( msg, model.state ) of
        ( EditTodoPageMsg editMsg, EditTodo todo ) ->
            EditTodoPage.update config editMsg (Maybe.withDefault Todo.initialModel todo)
                |> Tuple.mapFirst (\newTodo -> { model | state = EditTodo (Just newTodo) })
                |> Tuple.mapSecond (Cmd.map EditTodoPageMsg)

        ( HomePageMsg homeMsg, Home todos ) ->
            HomePage.update config homeMsg todos
                |> Tuple.mapFirst (\newTodos -> { model | state = Home newTodos })
                |> Tuple.mapSecond (Cmd.map HomePageMsg)

        ( NewTodoPageMsg formControlMsg, NewTodo currentTodo ) ->
            NewTodoPage.update config formControlMsg currentTodo
                |> Tuple.mapFirst (\newTodo -> { model | state = NewTodo newTodo })
                |> Tuple.mapSecond (Cmd.map NewTodoPageMsg)

        ( SessionsPageMsg formControlMsg, Session currentUser ) ->
            let
                ( formData, cmd, authState ) =
                    SessionsPage.update model.key formControlMsg currentUser
            in
            ( { model | state = Session formData, authState = authState }, Cmd.map SessionsPageMsg cmd )

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
                    case model.state of
                        ShowTodo _ ->
                            ( { model | state = ShowTodo (Just todo) }, Cmd.none )

                        EditTodo _ ->
                            ( { model | state = EditTodo (Just todo) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ( GotTodos response, _ ) ->
            case response of
                Ok todos ->
                    ( { model | state = Home todos }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ( LogOut, _ ) ->
            ( { model | state = Session Signin.initialModel, authState = NotAuthenticated }
            , Cmd.batch
                [ clearAuthInfo JE.null
                , Nav.pushUrl model.key (UB.absolute [ "sign-in" ] [])
                ]
            )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )



-- INIT


init : JD.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    case decodeFlags flags of
        Just authToken ->
            getCurrentPageData (initialModel navKey (Authenticated authToken)) url

        Nothing ->
            ( initialModel navKey NotAuthenticated
            , Nav.pushUrl navKey (UB.absolute [ "sign-in" ] [])
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


navView : Model -> Html Msg
navView model =
    let
        isLoggedIn =
            case model.authState of
                Authenticated _ ->
                    True

                NotAuthenticated ->
                    False
    in
    div
        [ class "container-fluid"
        , style "margin-bottom" "2rem"
        ]
        [ nav [ class "navbar" ]
            [ a [ class "navbar-brand", href "/" ] [ text "Company Logo" ]
            , if isLoggedIn then
                button [ class "navbar-brand btn btn-info text-white", onClick LogOut ] [ text "Log out" ]

              else
                text ""
            ]
        ]


pageTitle : Model -> String
pageTitle model =
    case model.state of
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

        EditTodo maybeTodo ->
            case maybeTodo of
                Just todo ->
                    todo.title

                Nothing ->
                    "Loading"

        Session _ ->
            "Log in"

        NoPageFound ->
            "Page not found"


pageBody : Model -> Html Msg
pageBody { key, state } =
    let
        body =
            case state of
                Home todos ->
                    HomePage.view todos
                        |> List.map (\msg -> Html.map HomePageMsg msg)

                NewTodo todo ->
                    (NewTodoPage.view todo
                        |> Html.map NewTodoPageMsg
                    )
                        :: []

                ShowTodo todo ->
                    ShowTodoPage.view todo :: []

                EditTodo todo ->
                    case todo of
                        Just formData ->
                            (EditTodoPage.view formData
                                |> Html.map EditTodoPageMsg
                            )
                                :: []

                        Nothing ->
                            text "Loading" :: []

                Session user ->
                    (SessionsPage.view user
                        |> Html.map SessionsPageMsg
                    )
                        :: []

                NoPageFound ->
                    PageNotFound.view :: []
    in
    div [ class "container" ] body


view : Model -> Document Msg
view model =
    { title = pageTitle model
    , body =
        [ navView model
        , pageBody model
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


fetchTodos : Model -> Cmd Msg
fetchTodos model =
    let
        authToken =
            case model.authState of
                Authenticated token ->
                    token

                NotAuthenticated ->
                    ""
    in
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" authToken
            ]
        , url = backendDomain ++ UB.absolute [ "todos" ] []
        , body = Http.emptyBody
        , expect = Http.expectJson GotTodos todosListDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


fetchTodo : Model -> Int -> Cmd Msg
fetchTodo model todoId =
    let
        authToken =
            case model.authState of
                Authenticated token ->
                    token

                NotAuthenticated ->
                    ""
    in
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" authToken
            ]
        , url = backendDomain ++ UB.absolute [ "todos", String.fromInt todoId ] []
        , body = Http.emptyBody
        , expect = Http.expectJson GotTodo todoDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
