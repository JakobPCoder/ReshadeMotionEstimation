/*
# ReshadeMotionEstimation
- Dense Realtime Motion Estimation | Based on Block Matching and Pyramids 
- Developed from 2019 to 2022 
- First published 2022 - Copyright, Jakob Wapenhensch
 
# This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0) License
- https://creativecommons.org/licenses/by-nc/4.0/
- https://creativecommons.org/licenses/by-nc/4.0/legalcode

# Human-readable summary of the License and not a substitute for https://creativecommons.org/licenses/by-nc/4.0/legalcode:
You are free to:
- Share — copy and redistribute the material in any medium or format
- Adapt — remix, transform, and build upon the material
- The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:
- Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- NonCommercial — You may not use the material for commercial purposes.
- No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

Notices:
- You do not have to comply with the license for elements of the material in the public domain or where your use is permitted by an applicable exception or limitation.
- No warranties are given. The license may not give you all of the permissions necessary for your intended use. For example, other rights such as publicity, privacy, or moral rights may limit how you use the material.
*/

#include "ReShadeUI.fxh"


uniform int  UI_ME_SAMPLES_PER_ITERATION < __UNIFORM_SLIDER_INT1
	ui_min = 3; ui_max = 8; ui_step = 1;
	ui_tooltip = "Select how many differnt Direction are sampled per Iteration.\n\
HIGH PERFORMANCE IMPACT";
	ui_label = "Samples per Iteration";
	ui_category = "Motion Estimation Block Matching";
> = 5;


uniform int  UI_ME_SUB_PIXEL_DETAIL < __UNIFORM_SLIDER_INT1
	ui_min = 0; ui_max = 4; ui_step = 1;
	ui_tooltip = "Select how many additional Search Iterations are to be done on the last Layer. Each Iteration is 2x more precise than the last one.\n\
0 -> 1 pixel accuracy | 1 -> 1/2 pixel accuracy | 2 -> 1/4 pixel accuracy | 3 - 1/8 pixel | 4 - 1/16 pixel\n\
HIGH PERFORMANCE IMPACT";
	ui_label = "Sub Pixel Accuracy";
	ui_category = "Motion Estimation Block Matching";
> = 1;

//Pyramid

uniform int  UI_ME_PYRAMID_UPSCALE_SAMPLES < __UNIFORM_SLIDER_INT1
	ui_min = 2; ui_max = 12; ui_step = 1;
	ui_tooltip = "Select how many Samples are taken when Upscaling Vectors from one Layer to the Next.\n\
MEDIUM PERFORMANCE IMPACT";
	ui_label = "Uplscale Filer Samples";
	ui_category = "Pyramid Upscaling";
> = 7;


uniform float  UI_ME_PYRAMID_UPSCALE_FILTER_RADIUS < __UNIFORM_SLIDER_FLOAT1
	ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
	ui_tooltip = "Select how large the Filter Radius is when Upscaling Vectors from one Layer to the Next.\n\
NO PERFORMANCE IMPACT";
	ui_label = "Filer Radius";
	ui_category = "Pyramid Upscaling";
> = 7.0;


//Debug_________________________
uniform bool UI_DEBUG_ENABLE <
    ui_label = "Debug View";
    ui_tooltip = "Activates Debug View";
    ui_category = "Debug";
> = false;

uniform int UI_DEBUG_MOTION_ZERO <
	ui_type = "combo";
    ui_label = "Motion Debug Background Color";
	ui_items = "White\0Gray\0Black\0";
	ui_tooltip = "";
	ui_category = "Debug";
> = 1;

uniform float UI_DEBUG_MULT < __UNIFORM_SLIDER_FLOAT1
	ui_min = 1.0; ui_max = 100.0; ui_step = 1;
	ui_tooltip = "Use this is the Debug Output is hard to see";
	ui_label = "Debug Multiplier";
	ui_category = "Debug";
> = 25.0;
