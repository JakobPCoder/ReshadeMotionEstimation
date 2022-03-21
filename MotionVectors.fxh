/** 
 * - Dense Realtime Motion Estimation | Based on Block Matching and Pyramids 
 * - Developed from 2019 to 2022 
 * - First published 2022 - Copyright, Jakob Wapenhensch
 */

/**
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0) License: https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode
 *
 * Human-readable summary:
 *
 * You are free to:
 * - Share -> copy and redistribute the material in any medium or format
 * - The licensor cannot revoke these freedoms as long as you follow the license terms.
 *
 * Under the following terms:
 * - Attribution -> You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
 * - NonCommercial -> You may not use the material for commercial purposes.
 * - NoDerivatives -> If you remix, transform, or build upon the material, you may not distribute the modified material. 
 * - No additional restrictions -> You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
 */

/**
 * Notice by the Author:
 * - Developing other Reshade.fx shader files that include "MotionVector.fxh" is NOT considered a derivative of my work by me. So you are good to go :)
 * - If you think you improved upon the actual algorithm contact me and if it is an improvement i will update the repo.
 * - Have Fun! j.w.
 */
 

#include "ReShade.fxh"

//Motion Vectors
texture texMotionVectors < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RG16F; };
sampler SamplerMotionVectors { Texture = texMotionVectors; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

//Easy way to sample the velocity buffer
float2 sampleMotion(float2 texcoord)
{
    return tex2D(SamplerMotionVectors, texcoord).rg;
}
