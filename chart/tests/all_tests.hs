import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Drawing
import Graphics.Rendering.Chart.Simple
import Graphics.Rendering.Chart.Grid

import System.Environment(getArgs)
import System.Time
import System.Random
import Data.Time.LocalTime
import Data.Accessor
import Data.Accessor.Tuple
import Data.Colour
import Data.Colour.Names
import Data.Colour.SRGB
import Data.List(sort,nub,scanl1)
import qualified Data.Map as Map
import Control.Monad
import Prices
import qualified Test1
import qualified Test2
import qualified Test3
import qualified Test4
import qualified Test5
import qualified Test6
import qualified Test7
import qualified Test8
import qualified Test9
import qualified Test14
import qualified Test14a
import qualified Test15
import qualified Test17
import qualified TestParametric
import qualified TestSparkLines

data OutputType = PNG | PS | PDF | SVG

chooseLineWidth PNG = 1.0
chooseLineWidth PDF = 0.25
chooseLineWidth PS = 0.25
chooseLineWidth SVG = 0.25

fwhite = solidFillStyle $ opaque white

test1a :: Double -> Renderable ()
test1a lwidth = fillBackground fwhite $ (gridToRenderable t)
  where
    t = weights (1,1) $ aboveN [ besideN [rf g1, rf g2, rf g3],
                                 besideN [rf g4, rf g5, rf g6] ]

    g1 = layout1_title ^= "minimal"
       $ layout1_bottom_axis ^: laxis_override ^= (axisGridHide.axisTicksHide)
       $ layout1_left_axis ^: laxis_override ^= (axisGridHide.axisTicksHide)
       $ Test1.layout lwidth

    g2 = layout1_title ^= "with borders"
       $ layout1_bottom_axis ^: laxis_override ^= (axisGridHide.axisTicksHide)
       $ layout1_left_axis ^: laxis_override ^= (axisGridHide.axisTicksHide)
       $ layout1_top_axis ^: axisBorderOnly
       $ layout1_right_axis ^: axisBorderOnly
       $ Test1.layout lwidth

    g3 = layout1_title ^= "default"
       $ Test1.layout lwidth

    g4 = layout1_title ^= "tight grid"
       $ layout1_left_axis ^: laxis_generate ^= axis
       $ layout1_left_axis ^: laxis_override ^= axisGridAtTicks
       $ layout1_bottom_axis ^: laxis_generate ^= axis
       $ layout1_bottom_axis ^: laxis_override ^= axisGridAtTicks
       $ Test1.layout lwidth
      where
        axis = autoScaledAxis (
            la_nLabels ^= 5
          $ la_nTicks ^= 20
          $ defaultLinearAxis
          )

    g5 = layout1_title ^= "y linked"
       $ layout1_yaxes_control ^= linkAxes
       $ Test1.layout lwidth

    g6 = layout1_title ^= "everything"
       $ layout1_yaxes_control ^= linkAxes
       $ layout1_top_axis ^: laxis_visible ^= const True
       $ Test1.layout lwidth

    rf = tval.toRenderable

    axisBorderOnly = (laxis_visible ^= const True)
                   . (laxis_override ^=  (axisGridHide.axisTicksHide.axisLabelsHide))

----------------------------------------------------------------------
test4d :: OutputType -> Renderable ()
test4d otype = toRenderable layout
  where

    points = plot_points_style ^= filledCircles 3 (opaque red)
           $ plot_points_values ^= [ (x, 10**x) | x <- [0.5,1,1.5,2,2.5::Double] ]
           $ plot_points_title ^= "values"
           $ defaultPlotPoints

    lines = plot_lines_values ^= [ [(x, 10**x) | x <- [0,3]] ]
          $ plot_lines_title ^= "values"
          $ defaultPlotLines

    layout = layout1_title ^= "Log/Linear Example"
           $ layout1_bottom_axis ^: laxis_title ^= "horizontal"
           $ layout1_bottom_axis ^: laxis_reverse ^= False
           $ layout1_left_axis ^: laxis_generate ^= autoScaledLogAxis defaultLogAxis
           $ layout1_left_axis ^: laxis_title ^= "vertical"
           $ layout1_left_axis ^: laxis_reverse ^= False
	   $ layout1_plots ^= [Left (toPlot points `joinPlot` toPlot lines) ]
           $ defaultLayout1

----------------------------------------------------------------------

test9 :: PlotBarsAlignment -> OutputType -> Renderable ()
test9 alignment otype = fillBackground fwhite $ (gridToRenderable t)
  where
    t = weights (1,1) $ aboveN [ besideN [rf g0, rf g1, rf g2],
                                 besideN [rf g3, rf g4, rf g5] ]

    g0 = layout "clustered 1"
       $ plot_bars_style ^= BarsClustered
       $ plot_bars_spacing ^= BarsFixWidth 25
       $ bars1

    g1 = layout "clustered/fix width "
       $ plot_bars_style ^= BarsClustered
       $ plot_bars_spacing ^= BarsFixWidth 25
       $ bars2

    g2 = layout "clustered/fix gap "
       $ plot_bars_style ^= BarsClustered
       $ plot_bars_spacing ^= BarsFixGap 10 5
       $ bars2

    g3 = layout "stacked 1"
       $ plot_bars_style ^= BarsStacked
       $ plot_bars_spacing ^= BarsFixWidth 25
       $ bars1

    g4 = layout "stacked/fix width"
       $ plot_bars_style ^= BarsStacked
       $ plot_bars_spacing ^= BarsFixWidth 25
       $ bars2

    g5 = layout "stacked/fix gap"
       $ plot_bars_style ^= BarsStacked
       $ plot_bars_spacing ^= BarsFixGap 10 5
       $ bars2

    rf = tval.toRenderable

    alabels = [ "Jun", "Jul", "Aug", "Sep", "Oct" ]


    layout title bars =
             layout1_title ^= (show alignment ++ "/" ++ title)
           $ layout1_title_style ^: font_size ^= 10
           $ layout1_bottom_axis ^: laxis_generate ^= autoIndexAxis alabels
           $ layout1_left_axis ^: laxis_override ^= (axisGridHide.axisTicksHide)
           $ layout1_plots ^= [ Left (plotBars bars) ]
           $ defaultLayout1 :: Layout1 PlotIndex Double

    bars1 = plot_bars_titles ^= ["Cash"]
          $ plot_bars_values ^= addIndexes [[20],[45],[30],[70]]
          $ plot_bars_alignment ^= alignment
          $ defaultPlotBars

    bars2 = plot_bars_titles ^= ["Cash","Equity"]
          $ plot_bars_values ^= addIndexes [[20,45],[45,30],[30,20],[70,25]]
          $ plot_bars_alignment ^= alignment
          $ defaultPlotBars

-------------------------------------------------------------------------------

test10 :: [(LocalTime,Double,Double)] -> OutputType -> Renderable ()
test10 prices otype = toRenderable layout
  where

    lineStyle c = line_width ^= 3 * chooseLineWidth otype
                $ line_color ^= c
                $ defaultPlotLines ^. plot_lines_style

    price1 = plot_lines_style ^= lineStyle (opaque blue)
           $ plot_lines_values ^= [[ (d,v) | (d,v,_) <- prices]]
           $ plot_lines_title ^= "price 1"
           $ defaultPlotLines

    price1_area = plot_fillbetween_values ^= [(d, (v * 0.95, v * 1.05)) | (d,v,_) <- prices]
                $ plot_fillbetween_style  ^= solidFillStyle (withOpacity blue 0.2)
                $ defaultPlotFillBetween

    price2 = plot_lines_style ^= lineStyle (opaque red)
	   $ plot_lines_values ^= [[ (d, v) | (d,_,v) <- prices]]
           $ plot_lines_title ^= "price 2"
           $ defaultPlotLines

    price2_area = plot_fillbetween_values ^= [(d, (v * 0.95, v * 1.05)) | (d,_,v) <- prices]
                $ plot_fillbetween_style  ^= solidFillStyle (withOpacity red 0.2)
                $ defaultPlotFillBetween

    fg = opaque black
    fg1 = opaque $ sRGB 0.0 0.0 0.15

    layout = layout1_title ^="Price History"
           $ layout1_background ^= solidFillStyle (opaque white)
           $ layout1_right_axis ^: laxis_override ^= axisGridHide
 	   $ layout1_plots ^= [ Left (toPlot price1_area), Right (toPlot price2_area)
                              , Left (toPlot price1),      Right (toPlot price2)
                              ]
           $ setLayout1Foreground fg
           $ defaultLayout1

-------------------------------------------------------------------------------
-- A quick test of stacked layouts

test11_ f = f layout1 layout2
  where
    vs1 :: [(Int,Int)]
    vs1 = [ (2,2), (3,40), (8,400), (12,60) ]

    vs2 :: [(Int,Double)]
    vs2 = [ (0,0.7), (3,0.35), (4,0.25), (7, 0.6), (10,0.4) ]

    plot1 = plot_points_style ^= filledCircles 5 (opaque red)
          $ plot_points_values ^= vs1
          $ plot_points_title ^= "spots"
          $ defaultPlotPoints

    layout1 = layout1_title ^= "Multi typed stack"
 	   $ layout1_plots ^= [Left (toPlot plot1)]
           $ layout1_left_axis ^: laxis_title ^= "integer values"
           $ defaultLayout1

    plot2 = plot_lines_values ^= [vs2]
          $ plot_lines_title ^= "lines"
          $ defaultPlotLines

    layout2 = layout1_plots ^= [Left (toPlot plot2)]
           $ layout1_left_axis ^: laxis_title ^= "double values"
           $ defaultLayout1

test11a :: OutputType -> Renderable ()
test11a otype = test11_ f
   where
     f l1 l2 = renderStackedLayouts 
             $ slayouts_layouts ^= [StackedLayout l1, StackedLayout l2]
             $ slayouts_compress_xlabels ^= False
             $ slayouts_compress_legend ^= False
             $ defaultStackedLayouts
 
test11b :: OutputType -> Renderable ()
test11b otype = test11_ f
   where
     f l1 l2 = renderStackedLayouts 
             $ slayouts_layouts ^= [StackedLayout l1, StackedLayout l2]
             $ slayouts_compress_xlabels ^= True
             $ slayouts_compress_legend ^= True
             $ defaultStackedLayouts

-------------------------------------------------------------------------------
-- More of an example that a test:
-- configuring axes explicitly configured axes

test12 :: OutputType -> Renderable ()
test12 otype = toRenderable layout
  where
    vs1 :: [(Int,Int)]
    vs1 = [ (2,10), (3,40), (8,400), (12,60) ]

    baxis = AxisData {
        axis_viewport_ = vmap (0,15),
        axis_tropweiv_ = invmap (0,15),
        axis_ticks_    = [(v,3) | v <- [0,1..15]],
        axis_grid_     = [0,5..15],
        axis_labels_   = [[(v,show v) | v <- [0,5..15]]]
    }    

    laxis = AxisData {
        axis_viewport_ = vmap (0,500),
        axis_tropweiv_ = invmap (0,500),
        axis_ticks_    = [(v,3) | v <- [0,25..500]],
        axis_grid_     = [0,100..500],
        axis_labels_   = [[(v,show v) | v <- [0,100..500]]]
    }    

    plot = plot_lines_values ^= [vs1]
         $ defaultPlotLines

    layout = layout1_plots ^= [Left (toPlot plot)]
           $ layout1_bottom_axis ^: laxis_generate ^= const baxis
           $ layout1_left_axis   ^: laxis_generate ^= const laxis
           $ layout1_title ^= "Explicit Axes"
           $ defaultLayout1


-------------------------------------------------------------------------------
-- Plot annotations test

test13 otype = fillBackground fwhite $ (gridToRenderable t)
  where
    t = weights (1,1) $ aboveN [ besideN [tval (annotated h v) | h <- hs] | v <- vs ]
    hs = [HTA_Left, HTA_Centre, HTA_Right]
    vs = [VTA_Top, VTA_Centre, VTA_Bottom]
    points=[-2..2]
    pointPlot :: PlotPoints Int Int
    pointPlot = plot_points_style^= filledCircles 2 (opaque red)
                $  plot_points_values ^= [(x,x)|x<-points]
                $  defaultPlotPoints
    p = Left (toPlot pointPlot)
    annotated h v = toRenderable ( layout1_plots ^= [Left (toPlot labelPlot), Left (toPlot rotPlot), p] $ defaultLayout1 )
      where labelPlot = plot_annotation_hanchor ^= h
                      $ plot_annotation_vanchor ^= v
                      $ plot_annotation_values  ^= [(x,x,"Hello World\n(plain)")|x<-points]
                      $ defaultPlotAnnotation
            rotPlot =   plot_annotation_angle ^= -45.0
                      $ plot_annotation_style ^= defaultFontStyle{font_size_=10,font_weight_=FontWeightBold, font_color_ =(opaque blue) }
                      $ plot_annotation_values  ^= [(x,x,"Hello World\n(fancy)")|x<-points]
                      $ labelPlot


----------------------------------------------------------------------
-- a quick test to display labels with all combinations
-- of anchors
misc1 rot otype = fillBackground fwhite $ (gridToRenderable t)
  where
    t = weights (1,1) $ aboveN [ besideN [tval (lb h v) | h <- hs] | v <- vs ]
    lb h v = addMargins (20,20,20,20) $ fillBackground fblue $ crossHairs $ rlabel fs h v rot s
    s = "Labelling"
    hs = [HTA_Left, HTA_Centre, HTA_Right]
    vs = [VTA_Top, VTA_Centre, VTA_Bottom]
    fwhite = solidFillStyle $ opaque white
    fblue = solidFillStyle $ opaque $ sRGB 0.8 0.8 1
    fs = defaultFontStyle{font_size_=20,font_weight_=FontWeightBold}
    crossHairs r =Renderable {
      minsize = minsize r,
      render = \sz@(w,h) -> do
          let xa = w / 2
          let ya = h / 2
          strokePath [Point 0 ya,Point w ya]
          strokePath [Point xa 0,Point xa h]
          render r sz
    }

----------------------------------------------------------------------
stdSize = (640,480)

allTests :: [ (String, (Int,Int), OutputType -> Renderable ()) ]
allTests =
     [ ("test1",  stdSize, \o -> Test1.chart (chooseLineWidth o) )
     , ("test1a", stdSize, \o -> test1a (chooseLineWidth o) )
     , ("test2a", stdSize, \o -> Test2.chart prices    False (chooseLineWidth o))
     , ("test2b", stdSize, \o -> Test2.chart prices1   False (chooseLineWidth o))
     , ("test2c", stdSize, \o -> Test2.chart prices2   False (chooseLineWidth o))
     , ("test2d", stdSize, \o -> Test2.chart prices5   True  (chooseLineWidth o))
     , ("test2e", stdSize, \o -> Test2.chart prices6   True  (chooseLineWidth o))
     , ("test2f", stdSize, \o -> Test2.chart prices7   True  (chooseLineWidth o))
     , ("test2g", stdSize, \o -> Test2.chart prices3   False (chooseLineWidth o))
     , ("test2h", stdSize, \o -> Test2.chart prices8   True  (chooseLineWidth o))
     , ("test2i", stdSize, \o -> Test2.chart prices9   True  (chooseLineWidth o))
     , ("test2j", stdSize, \o -> Test2.chart prices10  True  (chooseLineWidth o))
     , ("test2k", stdSize, \o -> Test2.chart prices10a True  (chooseLineWidth o))
     , ("test2m", stdSize, \o -> Test2.chart prices11  True  (chooseLineWidth o))
     , ("test2n", stdSize, \o -> Test2.chart prices10b True  (chooseLineWidth o))
     , ("test2o", stdSize, \o -> Test2.chart prices12  True  (chooseLineWidth o))
     , ("test2p", stdSize, \o -> Test2.chart prices13  True  (chooseLineWidth o))
     , ("test2q", stdSize, \o -> Test2.chart prices13a True  (chooseLineWidth o))
     , ("test2r", stdSize, \o -> Test2.chart prices13b True  (chooseLineWidth o))
     , ("test2s", stdSize, \o -> Test2.chart prices14  True  (chooseLineWidth o))
     , ("test2t", stdSize, \o -> Test2.chart prices14a True  (chooseLineWidth o))
     , ("test2u", stdSize, \o -> Test2.chart prices14b True  (chooseLineWidth o))
     , ("test2v", stdSize, \o -> Test2.chart prices14c True  (chooseLineWidth o))
     , ("test2w", stdSize, \o -> Test2.chart prices14d True  (chooseLineWidth o))
     , ("test3",  stdSize,  const Test3.chart)
     , ("test4a", stdSize, const (Test4.chart False False))
     , ("test4b", stdSize, const (Test4.chart True False))
     , ("test4c", stdSize, const (Test4.chart False True))
     , ("test4d", stdSize, test4d)
     , ("test5",  stdSize, \o -> Test5.chart (chooseLineWidth o))
     , ("test6",  stdSize, const Test6.chart)
     , ("test7",  stdSize, const Test7.chart)
     , ("test8",  stdSize, const Test8.chart)
     , ("test9",  stdSize, const (Test9.chart True))
     , ("test9b", stdSize, const (Test9.chart False))
     , ("test9c", stdSize, test9 BarsCentered)
     , ("test9l", stdSize, test9 BarsLeft)
     , ("test9r", stdSize, test9 BarsRight)
     , ("test10", stdSize, test10 prices1)
     , ("test11a", stdSize, test11a)
     , ("test11b", stdSize, test11b)
     , ("test12", stdSize, test12)
     , ("test13", stdSize, test13)
     , ("test14", stdSize, \o -> Test14.chart (chooseLineWidth o) )
     , ("test14a", stdSize, \o -> Test14a.chart (chooseLineWidth o) )
     , ("test15a", stdSize, const (Test15.chart (LORows 2)))
     , ("test15b", stdSize, const (Test15.chart (LOCols 2)))
     , ("test17", stdSize,  \o -> Test17.chart (chooseLineWidth o))
     , ("misc1",  stdSize, setPickFn nullPickFn . misc1 0)
     , ("misc1a", stdSize, setPickFn nullPickFn . misc1 45)
     , ("parametric", stdSize, \o -> TestParametric.chart (chooseLineWidth o) )
     , ("sparklines", TestSparkLines.chartSize, const TestSparkLines.chart )
     ]

main = do
    args <- getArgs
    main1 args

main1 :: [String] -> IO ()
main1 ("--pdf":tests) = showTests tests renderToPDF
main1 ("--svg":tests) = showTests tests renderToSVG
main1 ("--ps":tests) = showTests tests renderToPS
main1 ("--png":tests) = showTests tests renderToPNG
main1 tests = showTests tests renderToPNG

showTests :: [String] -> ((String,(Int,Int),OutputType -> Renderable ()) -> IO()) -> IO ()
showTests tests ofn = mapM_ doTest (filter (match tests) allTests)
   where
     doTest (s,size,f) = do
       putStrLn (s ++ "... ")
       ofn (s,size,f)
     

match :: [String] -> (String,s,a) -> Bool
match [] t = True
match ts (s,_,_) = s `elem` ts

renderToPNG (n,(w,h),ir) = renderableToPNGFile (ir PNG) w h (n ++ ".png")
                           >> return ()
renderToPS  (n,(w,h),ir) = renderableToPSFile (ir PS) w h (n ++ ".ps")
renderToPDF (n,(w,h),ir) = renderableToPDFFile (ir PDF) w h (n ++ ".pdf")
renderToSVG (n,(w,h),ir) = renderableToSVGFile (ir SVG) w h (n ++ ".svg")
