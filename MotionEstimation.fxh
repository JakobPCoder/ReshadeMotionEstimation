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

// todo
/**
 *  add loss of lower levels
 * supress localy long vectors
 */


#include "MotionVectors.fxh"
#include "MotionEstimationUI.fxh"

// Defines

// Preprocessor settings
#ifndef PRE_BLOCK_SIZE_2_TO_7
 #define PRE_BLOCK_SIZE_2_TO_7	3   //[2 - 7]     
#endif


#define BLOCK_SIZE (PRE_BLOCK_SIZE_2_TO_7)

//NEVER change these!!!
#define BLOCK_SIZE_HALF (int(BLOCK_SIZE / 2))
#define BLOCK_AREA (BLOCK_SIZE * BLOCK_SIZE)

#define ME_PYR_DIVISOR (2)
#define ME_PYR_LVL_1_DIV (ME_PYR_DIVISOR)
#define ME_PYR_LVL_2_DIV (ME_PYR_LVL_1_DIV * ME_PYR_DIVISOR)
#define ME_PYR_LVL_3_DIV (ME_PYR_LVL_2_DIV * ME_PYR_DIVISOR)
#define ME_PYR_LVL_4_DIV (ME_PYR_LVL_3_DIV * ME_PYR_DIVISOR)
#define ME_PYR_LVL_5_DIV (ME_PYR_LVL_4_DIV * ME_PYR_DIVISOR)
#define ME_PYR_LVL_6_DIV (ME_PYR_LVL_5_DIV * ME_PYR_DIVISOR)
#define ME_PYR_LVL_7_DIV (ME_PYR_LVL_6_DIV * ME_PYR_DIVISOR)

//Math
#define M_PI 3.1415926535
#define M_F_R2D (180.f / M_PI)
#define M_F_D2R (1.0 / M_F_R2D)

// Textures 
texture texCur0 < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
texture texLast0 < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

texture texMotionFilterX < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; }; 

texture texGCur0 < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RG16F; };
texture texGLast0 < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RG16F; };
texture texMotionCur0 < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; }; 
//texture texMotionLast0 < pooled = false; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; }; 

texture texGCur1 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_1_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_1_DIV; Format = RG16F; };
texture texGLast1 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_1_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_1_DIV; Format = RG16F; };
texture texMotionCur1 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_1_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_1_DIV; Format = RGBA16F; };
//texture texMotionLast1 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_1_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_1_DIV; Format = RGBA16F; };

texture texGCur2 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_2_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_2_DIV; Format = RG16F; };
texture texGLast2 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_2_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_2_DIV; Format = RG16F; };
texture texMotionCur2 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_2_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_2_DIV; Format = RGBA16F; };
//texture texMotionLast2 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_2_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_2_DIV; Format = RGBA16F; };

texture texGCur3 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_3_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_3_DIV; Format = RG16F; };
texture texGLast3 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_3_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_3_DIV; Format = RG16F; };
texture texMotionCur3 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_3_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_3_DIV; Format = RGBA16F; };
//texture texMotionLast3 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_3_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_3_DIV; Format = RGBA16F; };

texture texGCur4 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_4_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_4_DIV; Format = RG16F; };
texture texGLast4 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_4_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_4_DIV; Format = RG16F; };
texture texMotionCur4 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_4_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_4_DIV; Format = RGBA16F; };
//texture texMotionLast4 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_4_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_4_DIV; Format = RGBA16F; };

texture texGCur5 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_5_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_5_DIV; Format = RG16F; };
texture texGLast5 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_5_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_5_DIV; Format = RG16F; };
texture texMotionCur5 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_5_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_5_DIV; Format = RGBA16F; };
//texture texMotionLast5 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_5_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_5_DIV; Format = RGBA16F; };

texture texGCur6 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_6_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_6_DIV; Format = RG16F; };
texture texGLast6 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_6_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_6_DIV; Format = RG16F; };
texture texMotionCur6 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_6_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_6_DIV; Format = RGBA16F; };
//texture texMotionLast6 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_6_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_6_DIV; Format = RGBA16F; };

texture texGCur7 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_7_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_7_DIV; Format = RG16F; };
texture texGLast7 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_7_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_7_DIV; Format = RG16F; };
texture texMotionCur7 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_7_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_7_DIV; Format = RGBA16F; };
//texture texMotionLast7 < pooled = false; > { Width = BUFFER_WIDTH / ME_PYR_LVL_7_DIV; Height = BUFFER_HEIGHT / ME_PYR_LVL_7_DIV; Format = RGBA16F; };

//smaa edge texture 
texture EdgesTex < pooled = true; > {	Width = BUFFER_WIDTH;	    Height = BUFFER_HEIGHT;	    Format = RG8;   };

uniform int framecount < source = "framecount"; >;

// Search Block
//Sampling
void getBlock(float2 center, out float2 block[BLOCK_AREA], sampler grayIn)
{
    [unroll]
    for (int x = 0; x < BLOCK_SIZE; x++)
    {
        [unroll]
        for (int y = 0; y < BLOCK_SIZE; y++)
        {
            block[(BLOCK_SIZE * y) + x] = tex2Doffset(grayIn, center, int2(x - BLOCK_SIZE_HALF, y - BLOCK_SIZE_HALF)).rg;
        }
    }
}

float2 sampleBlock(int2 coord, float2 block[BLOCK_AREA])
{
    int2 pos = clamp(coord, int2(0,0), int2(BLOCK_SIZE_HALF - 1, BLOCK_SIZE_HALF - 1));
    return block[(BLOCK_SIZE * coord.y) + coord.x];
}

//Feature Level
float getBlockFeatureLevel(float2 block[BLOCK_AREA])
{
	float2 average = 0;
	for (int i = 0; i < BLOCK_AREA; i++)
		average += block[i];
	average /= float(BLOCK_AREA);

	float2 diff = 0;
	for (int i = 0; i < BLOCK_AREA; i++)
		diff += abs(block[i] - average);	
    diff /= float(BLOCK_AREA);

	float noise = saturate(diff.x * 2);
    return noise;
}


//Loss
float perPixelLoss(float2 grayDepthA, float2 grayDepthB)
{
    float finalLoss = abs(grayDepthA.r - grayDepthB.r);

    return finalLoss;
}

float blockLoss(float2 blockA[BLOCK_AREA], float2 blockB[BLOCK_AREA])
{
    float summedLosses = 0;

    for (int i = 0; i < BLOCK_AREA; i++)
    {
        summedLosses += perPixelLoss(blockA[i], blockB[i]);
    }
    return (summedLosses / float(BLOCK_AREA));
}



// Motion Vectors
//Packing
float4 packGbuffer(float2 unpackedMotion, float featureLevel, float loss)
{
    return float4(unpackedMotion.x, unpackedMotion.y, featureLevel, loss);
}

float2 motionFromGBuffer(float4 gbuffer)
{
    return float2(gbuffer.r, gbuffer.g);
}


//Show motion vectors stuff
float3 HUEtoRGB(in float H)
{
	float R = abs(H * 6.f - 3.f) - 1.f;
	float G = 2 - abs(H * 6.f - 2.f);
	float B = 2 - abs(H * 6.f - 4.f);
	return saturate(float3(R,G,B));
}

float3 HSLtoRGB(in float3 HSL)
{
	float3 RGB = HUEtoRGB(HSL.x);
	float C = (1.f - abs(2.f * HSL.z - 1.f)) * HSL.y;
	return (RGB - 0.5f) * C + HSL.z;
}

float4 motionToLgbtq(float2 motion)
{
	float angle = atan2(motion.y, motion.x) * M_F_R2D;
	float dist = length(motion);
	float3 rgb = HSLtoRGB(float3((angle / 360.f) + 0.5, saturate(dist * UI_DEBUG_MULT), 0.5));

	if (UI_DEBUG_MOTION_ZERO == 2)
		rgb = (rgb - 0.5) * 2;
	if (UI_DEBUG_MOTION_ZERO == 0)
		rgb = 1 - ((rgb - 0.5) * 2);
	return float4(rgb.r, rgb.g, rgb.b, 0);
}


// Motion Estimation
//Get Directional Sample

float randFloatSeed2(float2 seed)
{
    return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453) * M_PI;
}

float2 getCircleSampleOffset(const int samplesOnCircle, const float radiusInPixels, const int sampleId, const float angleOffset)
{
	float angleDelta = 360.f / samplesOnCircle;
	float sampleAngle = angleOffset + ((angleDelta * sampleId) * M_F_D2R);
	float2 delta = float2((cos(sampleAngle) * radiusInPixels), (sin(sampleAngle) * radiusInPixels));
	return delta;
}


/**
 * Calculate motion for a specific layer based on pixel block comparison.
 *
 * @param coord Coordinates for the local block in the current frame.
 * @param searchStart Initial search coordinates for the comparison block in the last frame.
 * @param curBuffer Sampler for the current frame.
 * @param lastBuffer Sampler for the last frame.
 * @param iterations Number of search iterations.
 * @return Motion vector, features level, and loss in packed G-buffer format.
 */

float4 CalcMotionLayer(float2 coord, float2 searchStart, sampler curBuffer, sampler lastBuffer, const int iterations)
{
    // Extract a block of pixels from the current frame
    float2 localBlock[BLOCK_AREA];
    getBlock(coord, localBlock, curBuffer);

    // Extract a block of pixels from the last frame for comparison
    float2 searchBlock[BLOCK_AREA];
    getBlock(coord + searchStart, searchBlock, lastBuffer);

    // Assess suitability of local block for motion tracking
    float localLoss = blockLoss(localBlock, searchBlock);
    float localFeatures = getBlockFeatureLevel(localBlock);

    // Initialize tracking variables
    float lowestLoss = localLoss;
    float featuresAtLowestLoss = localFeatures;
    float2 bestMotion = float2(0, 0);
    float2 searchCenter = searchStart;

    // Initialize random value for stochastic sampling
    float randomValue = randFloatSeed2(coord) * 100;
    randomValue += randFloatSeed2(float2(randomValue, float(framecount % uint(8)))) * 360;

    // Iterate to improve motion estimation
    for (int i = 0; i < iterations; i++) 
    {
        // Update random value
        randomValue = randFloatSeed2(float2(randomValue, i * 16)) * 100;

        // Search neighborhood to find the offset that minimizes block loss
        for (int s = 0; s < UI_ME_SAMPLES_PER_ITERATION; s++) 
        {
            float2 pixelOffset = getCircleSampleOffset(UI_ME_SAMPLES_PER_ITERATION, 1, s, randomValue) / tex2Dsize(lastBuffer) / pow(2, i);
            float2 samplePos = coord + searchCenter + pixelOffset;
            float2 searchBlockB[BLOCK_AREA];
            getBlock(samplePos, searchBlockB, lastBuffer);
            float loss = blockLoss(localBlock, searchBlockB);

            // Update best match if a lower loss is found
            if (loss < lowestLoss)
            {
                lowestLoss = loss;
                bestMotion = pixelOffset;
                featuresAtLowestLoss = getBlockFeatureLevel(searchBlockB);
            }
        }
        // Update search center for the next iteration
        searchCenter += bestMotion;
        bestMotion = float2(0, 0);
    }

    // Pack and return the results
    return packGbuffer(searchCenter, featuresAtLowestLoss, lowestLoss);
}

//Upscale to next Pyramid layer while supressing wrong / unlikely vectors
float4 UpscaleMotion(float2 texcoord, sampler curLevelGray, sampler lowLevelGray, sampler lowLevelMotion)
{
	float summedWeights = 0.00001;
	float4 summedMotion = 0;

	float randomAngle = randFloatSeed2(texcoord) * 100;
	randomAngle += randFloatSeed2(float2(randomAngle, float(framecount % uint(8)))) * 360;


	for (int s = 0; s < UI_ME_PYRAMID_UPSCALE_SAMPLES; s++)	
	{
		float randomDistBase = randFloatSeed2(float2(randomAngle, s * 100)) * 100;
		float dist = 0.5 + ((randomDistBase) % uint(UI_ME_PYRAMID_UPSCALE_FILTER_RADIUS));

		float2 samplePos = texcoord + (getCircleSampleOffset(UI_ME_PYRAMID_UPSCALE_SAMPLES, dist, s, randomAngle) / tex2Dsize(lowLevelMotion));
		
		float4 motionSampleLowLevel = tex2D(lowLevelMotion, samplePos);

		float weightSpeed  		= 1.0 / (1.0 + (length(motionSampleLowLevel.rg * tex2Dsize(lowLevelMotion) * 0.1)));
		float weightFeatures   	= 0.5 + (motionSampleLowLevel.b * 1);

		float weight = weightSpeed * weightFeatures;

		summedWeights += weight;
		summedMotion += weight * motionSampleLowLevel;
	}
	
	return summedMotion / summedWeights;
}
