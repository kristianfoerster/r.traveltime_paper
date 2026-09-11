---
title: 'r.traveltime - A GRASS GIS addon to study overland flow dynamics based on landscape connectivity'
tags:
  - C
  - hydrology
  - GRASS GIS
authors:
  - name: Kristian Förster
    orcid: 0000-0001-7542-2820
    affiliation: 1
affiliations:
 - name: Weihenstephan-Triesdorf University of Applied Sciences, Institute of Ecology and Landscape, Germany
   index: 1
   ror: 00gzkxz88
date: 04 September 2026
bibliography: paper.bib

---

# Summary

`r.traveltime` is an addon raster module for the GRASS Geographic Information System (GIS) [@grass_development_team_grass_2026]. Based on terrain analyses, it computes a map of the travel time required for overland flow to reach the catchment's outlet from any given location within the catchment. Thus, the temporal evolution of flooding within a given catchment can be assessed. This is of high practical relevance, as it allows the time lag between rainfall occurrence and peak flooding to be approximated. This approach uses simplified hydrological computations [@muzik_flood_1996; @kilgore_development_1997; @melesse_storm_2004] and only requires terrain elevation maps as a minimum input. 

\autoref{fig:example} illustrates how this works: The map of terrain elevation (\autoref{fig:example}(a)) is first analyzed in terms of flow direction (not shown) and flow accumulation, which reflects the size of the upstream catchment area (\autoref{fig:example}(b)). These steps are already available in the GRASS GIS modules `r.fill.dir` and `r.watershed`, respectively. `r.traveltime` is designed to compute the travel time of overland flow on hillslope elements and in channel segments - a flow accumulation threshold helps to distinguish between both types of flow. This way, it links flow direction, flow accumulation and surface roughness, which are viewed as the main factors governing landscape connectivity, and computes a map of overland flow travel time (\autoref{fig:example}(c)). In order to understand different types of hydrological calculations, `r.traveltime` predicts overland flow assuming one of the following assumptions: (i) Each hillslope cell is considered individually in terms of flow length (shown in \autoref{fig:example}(c)), (ii) flow length is estimated by identifying the minimum upstream length to the ridge (watershed), or (iii) the maximum flow path is considered. These different options are compared to each other by means of histograms (\autoref{fig:example}(d)). These alternative formulations allow the sensitivity of travel-time estimates to the representation of upstream flow length to be explored. Moreover, an independent calculation using "Isochrones variable speed" in SAGA GIS is also displayed, which is a tool that evolved in parallel and which uses a different formulation of flow velocity and characteristic flow length. 

The histogram representation of the travel time map represents a space-time transformation, which is why approaches like `r.traveltime` fill a gap between methods that provide single measures of flow time (e.g., longest flow time in a catchment) on one side and more complex fully coupled hydrological-hydrodynamic simulations like `r.sim.water`in GRASS GIS on the other. `r.traveltime` was first announced in 2007 and has since been continuously maintained and adapted to new GRASS GIS versions along with improvements following users' feedback over almost 2 decades.

![Steps to compute travel times for the North Carolina sample dataset in `r.traveltime`. The Jupyter notebook published alongside the paper includes the code to reproduce these results from downloading the data, installing `r.traveltime` to histogram plotting.\label{fig:example}](figures/traveltime.pdf)


# Statement of need

Predicting flooding usually considers a temporal dimension, i.e., it is important to predict when flooding occurs as a response to rainfall. Likewise, hydrological modelling might consider a spatially distributed representation of processes [@refsgaard_terminology_1996], requesting a linkage to GIS data. According to this early reference on hydrological modelling, several types of models exist, whereby the classification is considered along three dimensions: (i) level of processes representation (i.e., complexity), (ii) time dimension (stationary model vs. models with increments of time, e.g., seconds to days), (iii) level of spatial distribution (i.e. spatial aggregation of landscape elements). If flooding is considered, short intervals in time are needed, which covers ranges from sub-hourly to daily time steps. While complex simulation tools exist [@mitasova_path_2004], which entail a high degree of complexity in all three categories (physically-based description, small temporal and spatial increments), simpler models still require a parameterization of temporal dynamics, e.g., through provision of measures of flow time in sub-catchments. `r.traveltime` addresses this requirement whenever complex simulations are out of scope, bearing practitioners in mind who need estimates of travel times to customize own calculations and parameterizing their own models. In this specific case, the histogram is used as a unit hydrograph derived from landscape connectivity. A very intuitive illustration of this type of the unit hydrograph and how it could be communicated is provided by @schulz_demonstrating_2018. This approach is mostly in line with the space-time transformation shown in the \autoref{fig:example} and goes beyond single measures of maximum flow time in a catchment [@maidment_handbook_1993].


# State of the field                                                                                                                  

The rapid development of GIS in 1990s provided the technical basis to provide these flow times, based on terrain and other information, referred to as "geomorphological" unit hydrograph [@muzik_flood_1996, @kilgore_development_1997, @melesse_storm_2004]. Approaches similar to `r.traveltime`, besides its broad theretical foundation from literature, are still rare and either emerge into simplifications in representing flow length and slopes or consider more complex simulations with time steps. Apart from `r.traveltime` in GRASS GIS, there is a tool called "Isochrones variable speed" [@al-smadi_incorporating_1998] in SAGA GIS, which evolved in parallel to and independently from `r.traveltime`. Likewise, @diakakis_method_2011 describes a multi-step approach to achieve similar results in ArcGIS. Besides their similarity, different hydrological assumptions exist in these apporaches. \autoref{tab:software} provides an overview of available approaches and highlights `r.traveltime`'s position between simple and complex methods and modelling approaches, respectively.

: Overwiew of different methods to study flooding under consideration the @refsgaard_terminology_1996 criteria. \label{tab:software}

| Approach | Processes |Spatial distr. | Temporal distr. | Main result | Reference |
|---|---|---|---|---|---|
| Flow length | No | Limited | No | Single Flow length to stream | - |
| Concentration time | Single empirical eq. | Limited | Limited | Single time measure | [@maidment_handbook_1993] |
| Scalgo Live | Fill sinks | Yes | No | Flooded volume map | [https://scalgo.com/](https://scalgo.com/) |
| `r.traveltime` | Simple hydrology | Yes | Yes (indirect) | Travel time map | - |
| SAGA Isochrones | Simple hydrology | Yes | Yes (indirect) | Travel time map | [@al-smadi_incorporating_1998] |
| `r.sim.water` | diffusive wave | Yes | Yes (full) | Modelled water level and velocity map | [@mitasova_path_2004]
| Scalgo TUFLOW | Full Shallow water eq. | Yes | Yes (full) | Modelled water level and velocity map | [@huxley_tuflow_2016] |

`r.traveltime` complements rather than replaces these approaches by providing an intermediate level of spatial and temporal representation: it resolves the distribution of travel times across a catchment without requiring a full hydrodynamic simulation. Moreover, through `g.extension` it is a readily available addon to GRASS and can be modified by users according to their own needs.

# Software design
`r.traveltime` emerged from a practical need to estimate the distribution of travel times in a catchment. This quantity depends on both upstream (flow accumulation) and downstream information (i.e., the outlet as reference point above which travel times are added along the flow path). This type of calculation is not possible using standard map calculation features, which is why the author decided in 2007 to create a new GRASS GIS raster addon, because of its well documented API and the existence of `r.example`[^1], a simple minimum code to develop own addons. A simple realization has been considered through the implementation of a recursive function `ttime()`, which calculates the travel time of water against gravity (i.e. in opposite direction a water drop would travel) from the outlet until it reaches all points along the watershed boundary. A recursive implementation - as summarized in the pseudocode below - acknowledges the cumulative nature of travel time along the upstream flow path, whilst being dependent on upstream area. This formulation avoids solving the problem through a series of steps of individual raster calculations provided by different modules.
```text
FUNCTION ttime(ftime):
	FOR each D8 direction:
		IF inflow():
			ttime(ftime+traveltime())
```
`ttime()` is called in the `main()` function with `ftime=0` for the outlet's location (provided by user). In this function, `inflow()` checks if tributary cells exist through a for loop. For each of these cells, `ttime()` is called, remembering the travel time from the current cell to the outlet `ftime`, which is added to the local travel time between the current and tributary cell being considered.

In November 2007, the first version of `r.traveltime` was announced via the GRASS GIS developer's mailing list and the Addon wiki list, including a link to the source code on the author's website. There, the code was revised in 2008 [@forster_rtraveltime_2026]. In 2012, `r.traveltime` has been added to the GRASS GIS Addons folder on the GRASS GIS svn server[^2]. The author suggested some minor modification to the GRASS GIS developers in 2014 and 2015, which have been committed to the svn repository in 2016, including technical modifications to raster input/output by the GRASS GIS maintainers. `r.traveltime` was also ported to the new GitHub repository in 2019 by the GRASS GIS developers, where it is still maintained and made available[^3]. Users' feedback has been collected over the course of this development timeline and known issues have been compiled in the documentation published alongside the source file in the repositories. The version described in the paper is available in a fork of the official repository: [https://github.com/kristianfoerster/grass-addons/tree/grass8/src/raster/r.traveltime](https://github.com/kristianfoerster/grass-addons/tree/grass8/src/raster/r.traveltime)


[^1]: [https://github.com/OSGeo/grass/tree/main/doc/examples/raster/r.example](https://github.com/OSGeo/grass/tree/main/doc/examples/raster/r.example) (09 Sep 2026)
[^2]: [https://trac.osgeo.org/grass/browser/grass-addons/grass6/raster/r.traveltime](https://trac.osgeo.org/grass/browser/grass-addons/grass6/raster/r.traveltime) (09 Sep 2026)
[^3]: [https://github.com/OSGeo/grass-addons/tree/grass8/src/raster/r.traveltime/](https://github.com/OSGeo/grass-addons/tree/grass8/src/raster/r.traveltime/) (09 Sep 2026)

# Research impact statement
`r.traveltime` has been used in at least seven scientific publications representing six countries (see \autoref{tab:studies}. It is worth noting that it has been also applied in contexts other than the original aim of predicting floods, e.g., tool development [@minelli_rclarkepy_2010], delineation of water protection areas [@koffi_konan_determination_2014; @kabore_cartographie_2022], sediment yield [@berteni_application_2021], and spatial planning [@legarda_garzon_exploring_2020].

: Selected scientific applications of `r.traveltime` \label{tab:studies}

| Reference | Location  | Objectives |
|:----------|:----------|:----------|
| @suprit_grass-gis-based_2010 | Talpona River, India | Provision of travel times for flood risk management|
| @minelli_rclarkepy_2010 | 3 catchments in Italy | Development of `r.clarke.py`, which calls `r.traveltime` to compute hydrographs based on rainfall input; comparison with empirical equation.|
| @koffi_konan_determination_2014, @koffi_mapping_2015 | Lagune Aghien, Côte d’Ivoire | Delineation of protection areas on the lagoon area depending on travel time |
| @corripio_analysis_2017 | Ésera River catchment, Spain   | Computation of travel times in sub-cacthment for hydrological modelling |
| @legarda_garzon_exploring_2020 | Abstracted catchments, data from UK | Histogram of travel times utlized to identify locations for natural flood management measures  |
| @berteni_sediment_2019, @berteni_application_2021 | Guerna catchment, Italy | Derivation of a unit hydrograph for rainfall runoff and sediment yield prediction |
| @kabore_cartographie_2022 | Barrages de Ouagadougou, Burkina Faso | Map of travel time employed to identify travel times to three reservoirs and intersection with pollution sources |

# Mathematics

The mathematical description, at least for the standard calculation method ("std" in \autoref{fig:example}), is available in the historical technical description [@forster_rtraveltime_2026]. The minimum and maximum approaches include a flowlength calculation before calling `ttime()` and the overland flow calculation is replaced by the approach described by @kilgore_development_1997.

# AI usage disclosure

Generative AI tools were used to assist with setting up the Binder environment, preparing search queries in languages other than English, and improving the language of this manuscript. They were not used to develop the software. All AI-assisted content was reviewed and verified by the author.

# Acknowledgements

The author would like to thanks the users of `r.traveltime` for their interest in the software and their feedback. Moreover, the author is grateful to the GRASS GIS developers for maintaining the addon in their official repositories over more than 10 years from GRASS version 6 to version 8.

# References