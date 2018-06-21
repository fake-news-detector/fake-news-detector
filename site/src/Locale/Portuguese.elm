module Locale.Portuguese exposing (..)

import Locale.Words exposing (LocaleKey(..))


translate : LocaleKey -> String
translate localeValue =
    case localeValue of
        Loading ->
            "Carregando..."

        FlagContent ->
            "Sinalizar conteúdo"

        FlagQuestion ->
            "Qual das opções abaixo define melhor este conteúdo?"

        FlagSubmitButton ->
            "Sinalizar"

        Legitimate ->
            "Legítimo"

        LegitimateDescription ->
            "Conteúdo honesto, não tenta enganar ninguém, de forma alguma"

        FakeNews ->
            "Fake News"

        FakeNewsDescription ->
            "Notícia falsa, engana o leitor, espalha boatos"

        Biased ->
            "Tendencioso"

        ExtremelyBiased ->
            "Extremamente Tendencioso"

        ExtremelyBiasedDescription ->
            "Mostra apenas um lado da história, interpreta de forma exagerada alguns pontos, sem ponderamento com outros"

        Satire ->
            "Sátira"

        SatireDescription ->
            "Conteúdo propositalmente falso, para fins humorísticos"

        NotNews ->
            "Não é notícia"

        NotNewsDescription ->
            "Meme, conteúdo pessoal ou qualquer outra coisa não jornalística"

        Clickbait ->
            "Clickbait"

        ClickbaitQuestion ->
            "O título é clickbait?"

        ClickbaitDescription ->
            "Título apelativo, não explica a notícia completa de propósito apenas para ganhar cliques"

        Yes ->
            "Sim"

        No ->
            "Não"

        DontKnow ->
            "Não sei"

        FillAllFields ->
            "Preencha todos os campos"

        Verified ->
            "(verificado)"

        FlagButton ->
            "🏴 Sinalizar"

        InvalidQueryError ->
            "Cole um texto, um link válido ou mais palavras-chave para checar"

        LoadingError ->
            "erro ao carregar"

        TimeoutError ->
            "Timeout: operação demorou tempo demais"

        NetworkError ->
            "Erro de rede: verifique sua conexão à internet"

        Explanation ->
            explanation

        Check ->
            "checar"

        PasteLink ->
            "Cole um link ou texto suspeito aqui, ou busque um boato por palavras-chave"

        FakeNewsDetector ->
            "Detector de Fake News"

        AddToChrome ->
            "Adicionar ao Chrome"

        AddToFirefox ->
            "Adicionar ao Firefox"

        RobinhosOpinion ->
            "Opinião do Robinho"

        PeoplesOpinion ->
            "Opinião das Pessoas"

        NothingWrongExample ->
            "Não parece ter nada de errado com este conteúdo. Quer um exemplo? "

        ClickHere ->
            "Clique aqui"

        HelpImproveResult ->
            "Acredita que este resultado está errado?"

        ContentFlagged ->
            "Conteúdo sinalizado, obrigado!"

        LooksLike ->
            "Parece"

        LooksALotLike ->
            "Parece muito"

        AlmostCertain ->
            "Tenho quase certeza que é"

        HelpRobinho ->
            "Corrija o Robinho"

        CheckYourself ->
            "Confira você mesmo"

        WeDidAGoogleSearch ->
            "Fizemos uma busca no Google com as palavras-chave extraídas do texto"

        TwitterSpread ->
            "Disseminação no Twitter"

        CheckHowItIsSpreading ->
            "Veja como isso está se espalhando pelo twitter"

        LoadingTweets ->
            "Carregando tweets..."

        NoTweetsFound ->
            "Nenhum tweet encontrado"

        YouNeedToSignInWithTwitter ->
            "Para montar o gráfico da disseminação, precisamos que você faça login com a sua conta do Twitter"

        SignInWithTwitter ->
            "Entrar com Twitter"


explanation : String
explanation =
    """

## O que é isso?

O Detector de Fake News te permite detectar e denunciar **Fake News**, **Click Baits** e notícias
**Extremamente Tendenciosas**, graças ao nosso robô, o [Robinho](https://github.com/fake-news-detector/fake-news-detector/tree/master/robinho).

Há varias formas de usar o Detector de Fake News:

- Instalando a extensão para o [Chrome](https://chrome.google.com/webstore/detail/fake-news-detector/alomdfnfpbaagehmdokilpbjcjhacabk)
ou [Firefox](https://addons.mozilla.org/en-US/firefox/addon/fakenews-detector/) que checa as notícias direto do seu feed do Twitter e Facebook
- Conversando diretamente com o Robinho [no Telegram](https://t.me/RobinhoFakeBot)
- Copiando e colando o link ou texto no campo acima para checar

## Como funciona?

Ao classificar uma notícia, outras pessoas que usam o Detector de Fake News vão ver a sua sinalização,
ficarão mais atentas e também poderão sinalizar. Essas informações são guardadas em um
banco de dados e são lidas pelo Robinho.

O Robinho se baseia na informação dada por nós humanos e vai aprendendo com o tempo a classificar
automaticamente uma notícia como Fake News, Click Bait, etc, pelo seu texto. Com isso, mesmo novas
notícias que ninguém nunca viu poderão ser rapidamente classificadas.

A extensão então mostra nas notícias do seu facebook ou twitter a avaliação do robô e das pessoas:

<img src="static/clickbait.png" width="471" alt="Extensão mostrando que uma notícia foi classificada como click bait no facebook" />

Ou, se você perguntar pra ele no Telegram, ele te diz:

<img src="static/telegram-hoax.png" width="471" alt="Conversa no Telegram mostrando um texto que foi classificado como fake news pelo Robinho" />

Quanto mais você avalia as notícias, mais você contribui para a construção de uma base para
ensinar e melhorar o Robinho, que ainda está bem no início do seu desenvolvimento, veja, ele ainda
é um bebê robô:

<img src="static/robinho.jpg" width="350" alt="Foto do Robinho">

<small>Créditos a <a href="http://www.paper-toy.fr/baby-robot-friend-de-drew-tetz/" target="_blank">Drew Tetz</a> pela foto</small> <br />
<small>Créditos a <a href="https://twitter.com/laurapaschoal" target="_blank">@laurapaschoal</a> pelo nome Robinho</small>

## Motivação

Em 2016, durante a eleição dos Estados Unidos, muitos sites de fake news foram criados,
e propagados através das redes sociais, principalmente do Facebook. Mas foram tantos,
que as Fake News tiveram
<a target="_blank" href="http://www.patheos.com/blogs/accordingtomatthew/2016/12/fake-news-stories-received-more-clicks-than-real-news-during-end-of-2016-election-season/">
mais cliques que as notícias reais.
</a>

Um dos casos mais icônicos foi o de um morador da Macedônia que tinha
<a target="_blank" href="https://www.wired.com/2017/02/veles-macedonia-fake-news/">mais de 100 sites de fake news registrados</a>,
chegando a ganhar milhares de dólares por mês com anúncios.

A maioria desses sites era pró-Trump, por que? O Macedônio era um defensor ferrenho do Trump?
Não necessariamente! Mas ele percebeu que o eleitorado do Trump era mais sucetível a acreditar
e propagar Fake News.

Agora, em 2018, teremos eleições no Brasil, e há muitas páginas por aí que não se preocupam em
conferir as fontes e podem se aproveitar (e já estão se aproveitando) da mesma estratégia
que beneficiou Donald Trump.

Além disso, ainda temos muitas publicações extremamente tendenciosas de todos os lados e
os irritantes click-baits.

O Detector de Fake News é uma pequena iniciativa para tentar fazer alguma diferença na luta contra
esse problema, unindo a boa vontade das pessoas (Crowdsourcing) com tecnologia (Machine Learning)

## Como contribuir

Só de baixar a extensão e sinalizar as notícias você já vai estar ajudando muito! Tanto outros
usuários, quanto no desenvolvimento do Robinho.

Mas se você é programador ou cientista de dados, o Detector de Fake News é um projeto de
código aberto que precisa muito da sua ajuda! Todos os repositórios estão disponíveis em:
[https://github.com/fake-news-detector](https://github.com/fake-news-detector).

As tecnologias também são muito empolgantes: usamos Elm com WebExtensions para
a extensão, Rust para a API e Python para Machine Learning. Não conhece? Não tem problema, afinal o objetivo do
projeto é justamente aprender essas tecnologias enquanto ajuda o mundo.

Se quiser ajudar, dê uma olhada no nosso [ROADMAP](https://github.com/fake-news-detector/fake-news-detector/blob/master/site/ROADMAP.md)
(em inglês) para entender a direção do projeto, e dê uma olhada também nas
[issues do github dos projetos](https://github.com/fake-news-detector).

Se você ficou interessado mas tem dúvidas de como pode ajudar, me procure no twitter,
[@_rchaves_](https://twitter.com/_rchaves_).

E siga o nosso perfil do twitter para notícias sobre Fake News e novidades do projeto:
[@fndetector](https://twitter.com/fndetector).
"""
