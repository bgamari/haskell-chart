-----------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.Chart
-- Copyright   :  (c) Tim Docker 2006
-- License     :  BSD-style (see chart/COPYRIGHT)
--
-- A Simple framework for creating 2D charts in Haskell.
--
-- The basic model is that you define a value of type 'Renderable',
-- typically by applying 'toRenderable' to some other value. This
-- 'Renderable' is then actually displayed or output by calling either
-- 'renderableToPNGFile', or 'Graphics.Rendering.Chart.Gtk.renderableToWindow'.
--
-- Currently, the only useful 'Renderable' for displaying charts
-- is created by applying 'toRenderable' to a value of type
-- 'Graphics.Rendering.Chart.Layout.Layout1'
-----------------------------------------------------------------------------

module Graphics.Rendering.Chart(
    Renderable(..),
    ToRenderable(..),
    Layout1(..),
    Axis(..),
    Plot(..),
    ToPlot(..),
    PlotPoints(..),
    PlotLines(..),
    PlotFillBetween(..),
    HAxis(..),
    VAxis(..),
    Rect(..),
    Point(..),
    defaultAxisLineStyle, 
    defaultPlotLineStyle,
    defaultAxis, 
    defaultPlotPoints,
    defaultPlotLines,
    defaultPlotFillBetween,
    defaultLayout1,
    filledCircles,
    solidLine,
    dashedLine,
    solidFillStyle,
    fontStyle,
    independentAxes,
    linkedAxes,
    linkedAxes',
    explicitAxis,
    autoScaledAxis,
    autoScaledLogAxis,
    monthsAxis,
    renderableToPNGFile,
    renderableToPDFFile,
    renderableToPSFile,
    doubleFromClockTime,
    clockTimeFromDouble,
    CairoLineStyle(..),
    CairoFillStyle(..),
    CairoFontStyle(..)
) where

import Graphics.Rendering.Chart.Types
import Graphics.Rendering.Chart.Renderable
import Graphics.Rendering.Chart.Layout
import Graphics.Rendering.Chart.Axis
import Graphics.Rendering.Chart.Plot