module Links exposing (..)

import Data.Category as Category
import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (td, th, tr)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Login exposing (User)
import RemoteData exposing (..)
import RemoteData.Http exposing (..)
import Return exposing (..)
import Set
import Stylesheet exposing (..)


type Msg
    = LoadLinks
    | LinksResponse (WebData (List Link))
    | VerifyLink LinkId CategoryId
    | VerifyLinkClickbaitTitle LinkId (Maybe Bool)
    | VerifyLinkResponse (WebData ())
    | ShowContent Int
    | RemoveContent LinkId
    | RemoveLinkResponse LinkId (WebData String)


type alias Model =
    { linksResponse : WebData (List Link)
    , verifyLinkResponse : WebData ()
    , showContent : Set.Set Int
    , removedLinks : Set.Set Int
    }


type LinkId
    = LinkId Int


type CategoryId
    = CategoryId Int
    | NoCategory


type alias Link =
    { id : LinkId
    , url : Maybe String
    , title : Maybe String
    , content : Maybe String
    , categoryId : Int
    , clickbaitTitle : Maybe Bool
    , verifiedCategoryId : Maybe Int
    , verifiedClickbaitTitle : Maybe Bool
    , count : Int
    }


init : Model
init =
    { linksResponse = NotAsked
    , verifyLinkResponse = NotAsked
    , showContent = Set.empty
    , removedLinks = Set.empty
    }


linksDecoder : Decoder (List Link)
linksDecoder =
    decode Link
        |> required "id" (Decode.map LinkId Decode.int)
        |> required "url" (nullable Decode.string)
        |> required "title" (nullable Decode.string)
        |> required "content" (nullable Decode.string)
        |> required "category_id" Decode.int
        |> required "clickbait_title" (nullable Decode.bool)
        |> required "verified_category_id" (nullable Decode.int)
        |> required "verified_clickbait_title" (nullable Decode.bool)
        |> required "count" Decode.int
        |> Decode.list


view : User -> Model -> Element Styles variation Msg
view user model =
    column None
        []
        [ row None
            [ spread, paddingBottom 30 ]
            [ h1 Title [] (text "Flagged Links")
            , el None
                [ alignBottom ]
                (case model.verifyLinkResponse of
                    Loading ->
                        text "Saving..."

                    Success _ ->
                        text "✅ Saved"

                    Failure _ ->
                        text "Error"

                    NotAsked ->
                        empty
                )
            ]
        , case model.linksResponse of
            Loading ->
                text "Loading..."

            Success links ->
                linksTable model links

            Failure _ ->
                text "Error"

            NotAsked ->
                empty
        ]


linksTable : Model -> List Link -> Element Styles variation Msg
linksTable model links =
    html <|
        Html.table
            [ Attr.attribute "border" "1"
            , Attr.attribute "cellpadding" "5"
            , Attr.attribute "width" "100%"
            ]
            ([ tr []
                [ th [ Attr.rowspan 2 ] [ Html.text "Title or Content" ]
                , th [ Attr.colspan 2 ] [ Html.text "Popular" ]
                , th [ Attr.colspan 2 ] [ Html.text "Verified" ]
                , th [ Attr.rowspan 2 ] [ Html.text "Delete Content" ]
                ]
             , tr []
                [ th [] [ Html.text "Category" ]
                , th [] [ Html.text "Clickbait Title" ]
                , th [] [ Html.text "Category" ]
                , th [] [ Html.text "Clickbait Title" ]
                ]
             ]
                ++ List.map (linkRow model) links
            )


linkRow : Model -> Link -> Html.Html Msg
linkRow model link =
    let
        isLink =
            String.contains "http" (Maybe.withDefault "" link.url)

        titleText =
            if isLink then
                Maybe.withDefault "" link.title
            else
                Maybe.withDefault "" link.content

        titleOrPlaceholderText =
            if String.isEmpty titleText then
                "No title"
            else
                titleText

        titleLink =
            if isLink then
                Html.a
                    [ Attr.href (Maybe.withDefault "" link.url)
                    , Attr.target "_blank"
                    ]
                    [ Html.text titleOrPlaceholderText ]
            else
                Html.div
                    [ Attr.style [ ( "max-height", "50px" ), ( "overflow-y", "scroll" ) ]
                    ]
                    [ Html.text titleOrPlaceholderText ]

        category =
            Category.fromId link.categoryId

        popularCategory =
            Html.text
                (Category.toEmoji category
                    ++ " "
                    ++ Category.toName category
                )

        verifyLinkEvent targetValue =
            String.toInt targetValue
                |> Result.map CategoryId
                |> Result.withDefault NoCategory
                |> VerifyLink link.id

        selectCategory =
            Html.select
                [ Attr.style [ ( "width", "100%" ) ]
                , Events.on "change" (Decode.map verifyLinkEvent Events.targetValue)
                ]
                ([ Html.option
                    [ Attr.value ""
                    , Attr.selected (link.verifiedCategoryId == Nothing)
                    ]
                    [ Html.text "" ]
                 ]
                    ++ List.map
                        (\id ->
                            Html.option
                                [ Attr.value <| toString id
                                , Attr.selected (link.verifiedCategoryId == Just id)
                                ]
                                [ Html.text (Category.toName <| Category.fromId id) ]
                        )
                        (List.range 1 6)
                )

        popularIsClickbaitTitle =
            Html.text
                (case link.clickbaitTitle of
                    Just True ->
                        "Yes"

                    Just False ->
                        "No"

                    Nothing ->
                        ""
                )

        verifyClickbaitTitleEvent targetValue =
            let
                clickbaitTitle =
                    case targetValue of
                        "True" ->
                            Just True

                        "False" ->
                            Just False

                        _ ->
                            Nothing
            in
            VerifyLinkClickbaitTitle link.id clickbaitTitle

        selectIsClickbait =
            Html.select
                [ Attr.style [ ( "width", "100%" ) ]
                , Events.on "change" (Decode.map verifyClickbaitTitleEvent Events.targetValue)
                ]
                ([ Html.option
                    [ Attr.value ""
                    , Attr.selected (link.verifiedClickbaitTitle == Nothing)
                    ]
                    [ Html.text "" ]
                 ]
                    ++ List.map
                        (\( name, value ) ->
                            Html.option
                                [ Attr.value <| toString value
                                , Attr.selected (link.verifiedClickbaitTitle == Just value)
                                ]
                                [ Html.text name ]
                        )
                        [ ( "Yes", True ), ( "No", False ) ]
                )

        showContent =
            case ( isLink, link.id ) of
                ( True, LinkId id ) ->
                    Html.span []
                        [ Html.text " "
                        , Html.button [ Events.onClick (ShowContent id) ] [ Html.text "Show/Hide content" ]
                        , if Set.member id model.showContent then
                            Html.text <| Maybe.withDefault "" link.content
                          else
                            Html.text ""
                        ]

                _ ->
                    Html.text ""

        deleteButton =
            Html.button [ Events.onClick (RemoveContent link.id) ] [ Html.text "Delete" ]

        hideIfRemoved (LinkId id) =
            if Set.member id model.removedLinks then
                Html.text ""
            else
                tr []
                    [ td [] [ titleLink, showContent ]
                    , td [] [ popularCategory ]
                    , td [] [ popularIsClickbaitTitle ]
                    , td [] [ selectCategory ]
                    , td [] [ selectIsClickbait ]
                    , td [] [ deleteButton ]
                    ]
    in
    hideIfRemoved link.id


update : Msg -> Model -> Return Msg Model
update msg model =
    case msg of
        LoadLinks ->
            return { model | linksResponse = Loading }
                (RemoteData.Http.get "/links/all" LinksResponse linksDecoder)

        LinksResponse linksResponse ->
            return { model | linksResponse = linksResponse } Cmd.none

        VerifyLink linkId categoryId ->
            return { model | verifyLinkResponse = Loading }
                (RemoteData.Http.post
                    "/admin/verify_link"
                    VerifyLinkResponse
                    (Decode.succeed ())
                    (verifyLinkEncoder linkId categoryId)
                )

        VerifyLinkClickbaitTitle linkId clickbaitTitle ->
            return { model | verifyLinkResponse = Loading }
                (RemoteData.Http.post
                    "/admin/verify_link_clickbait_title"
                    VerifyLinkResponse
                    (Decode.succeed ())
                    (verifyLinkClickbaitTitleEncoder linkId clickbaitTitle)
                )

        VerifyLinkResponse verifyLinkResponse ->
            return { model | verifyLinkResponse = verifyLinkResponse } Cmd.none

        ShowContent id ->
            return
                { model
                    | showContent =
                        if Set.member id model.showContent then
                            Set.remove id model.showContent
                        else
                            Set.insert id model.showContent
                }
                Cmd.none

        RemoveContent linkId ->
            return { model | verifyLinkResponse = Loading }
                (RemoteData.Http.delete
                    "/admin/remove_link"
                    (RemoveLinkResponse linkId)
                    (removeLinkEncoder linkId)
                )

        RemoveLinkResponse (LinkId id) response ->
            let
                removedLinks =
                    case response of
                        Success _ ->
                            Set.insert id model.removedLinks

                        _ ->
                            model.removedLinks
            in
            return
                { model
                    | removedLinks = removedLinks
                    , verifyLinkResponse = RemoteData.map (always ()) response
                }
                Cmd.none


verifyLinkEncoder : LinkId -> CategoryId -> Encode.Value
verifyLinkEncoder (LinkId linkId) categoryId =
    Encode.object
        [ ( "link_id", Encode.int linkId )
        , ( "category_id"
          , case categoryId of
                NoCategory ->
                    Encode.null

                CategoryId categoryId ->
                    Encode.int categoryId
          )
        ]


verifyLinkClickbaitTitleEncoder : LinkId -> Maybe Bool -> Encode.Value
verifyLinkClickbaitTitleEncoder (LinkId linkId) clickbaitTitle =
    Encode.object
        [ ( "link_id", Encode.int linkId )
        , ( "clickbait_title"
          , case clickbaitTitle of
                Nothing ->
                    Encode.null

                Just bool ->
                    Encode.bool bool
          )
        ]


removeLinkEncoder : LinkId -> Encode.Value
removeLinkEncoder (LinkId id) =
    Encode.object
        [ ( "link_id", Encode.int id )
        ]
