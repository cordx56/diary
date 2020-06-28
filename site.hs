--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Pandoc


--------------------------------------------------------------------------------
conf :: Configuration 
conf = defaultConfiguration {
    providerDirectory = "./src",
    destinationDirectory = "./dist",
    storeDirectory = "./.cache",
    tmpDirectory = "./.cache/tmp",
    previewHost = "0.0.0.0",
    previewPort = 8080
    }
--------------------------------------------------------------------------------
pandocReaderOpt = defaultHakyllReaderOptions {
    readerExtensions =
        enableExtension Ext_emoji $
        enableExtension Ext_east_asian_line_breaks $
        readerExtensions defaultHakyllReaderOptions
    }
pandocWriterOpt = defaultHakyllWriterOptions {
    writerTableOfContents = True,
    writerTOCDepth = 2
}
customPandocCompiler = pandocCompilerWith pandocReaderOpt pandocWriterOpt
--------------------------------------------------------------------------------
asciidocCompiler = do
    getResourceString >>= withItemBody (unixFilter "asciidoctor" [
        "-s",
        "-a", "skip-front-matter",
        "-"
        ])
--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith conf $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "CNAME" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**.md" $ do
        route $ setExtension "html"
        compile $ customPandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "posts/**.asc" $ do
        route $ setExtension "html"
        compile $ asciidocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    siteCtx

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 10) . recentFirst =<< loadAll "posts/**"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    siteCtx

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y %H:%M" `mappend`
    siteCtx
--------------------------------------------------------------------------------
siteCtx :: Context String
siteCtx =
    constField "site-title"       "diary"   `mappend`
    constField "site-description" "cordx56's diary" `mappend`
    defaultContext
