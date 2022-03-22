/** 
 * - Dense Realtime Motion Estimation | Based on Block Matching and Pyramids 
 * - Developed from 2019 to 2022 
 * - First published 2022 - Copyright, Jakob Wapenhensch
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
