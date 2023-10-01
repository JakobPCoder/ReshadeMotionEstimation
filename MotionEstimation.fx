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

#include "MotionEstimation.fxh"




// Samplers
sampler smpCur0 { Texture = texCur0; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpLast0 { Texture = texLast0; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };

sampler smpMotionFilterX { Texture = texMotionFilterX; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

//Pyr: 
//smpG samplers are .r = Grayscale, g = depth
//smgM samplers are .r = motion x, .g = motion y, .b = feature level, .a = loss;

sampler smpGCur0 { Texture = texGCur0; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast0 { Texture = texGLast0; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur0 { Texture = texMotionCur0; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
///sampler smpMLast0 { Texture = texMotionLast0; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };



sampler smpGCur1 { Texture = texGCur1; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast1 { Texture = texGLast1; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur1 { Texture = texMotionCur1; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
//sampler smpMLast1 { Texture = texMotionLast1; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

sampler smpGCur2 { Texture = texGCur2; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast2 { Texture = texGLast2; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur2 { Texture = texMotionCur2; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
//sampler smpMLast2 { Texture = texMotionLast2; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

sampler smpGCur3 { Texture = texGCur3; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast3 { Texture = texGLast3; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur3 { Texture = texMotionCur3; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
//sampler smpMLast3 { Texture = texMotionLast3; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

sampler smpGCur4 { Texture = texGCur4; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast4 { Texture = texGLast4; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur4 { Texture = texMotionCur4; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
//sampler smpMLast4 { Texture = texMotionLast4; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

sampler smpGCur5 { Texture = texGCur5; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast5 { Texture = texGLast5; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur5 { Texture = texMotionCur5; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
//sampler smpMLast5 { Texture = texMotionLast5; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

sampler smpGCur6 { Texture = texGCur6; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast6 { Texture = texGLast6; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur6 { Texture = texMotionCur6; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
//sampler smpMLast6 { Texture = texMotionLast6; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

sampler smpGCur7 { Texture = texGCur7; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpGLast7 { Texture = texGLast7; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Point; };
sampler smpMCur7 { Texture = texMotionCur7; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };
//sampler smpMLast7 { Texture = texMotionLast7; AddressU = Clamp; AddressV = Clamp; MipFilter = Point; MinFilter = Point; MagFilter = Point; };

sampler smpSmaaEdges { Texture = EdgesTex; AddressU = Clamp; AddressV = Clamp; MipFilter = Linear; MinFilter = Linear; MagFilter = Linear; };




// Passes
//Save old data and get new one
float4 SaveLastPS(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 last : SV_Target1, out float4 lastGray : SV_Target2/*, out float4 lastMotionLayer : SV_Target3*/) : SV_Target0
{	
	last = tex2D(smpCur0, texcoord);
	lastGray =  tex2D(smpGCur0, texcoord);
	//lastMotionLayer = tex2D(smpMCur0, texcoord);
	return tex2D(ReShade::BackBuffer, texcoord);
}

float2 CurToGrayPS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{	
	return float2((dot(tex2D(smpCur0, texcoord).rgb, float3(0.3, 0.5, 0.2))), ReShade::GetLinearizedDepth(texcoord));
}

//Save Old Pyramid
float4 SaveGray1PS(float4 position : SV_Position, float2 texcoord : TEXCOORD/*, out float4 lastMotionLayer : SV_Target1*/) : SV_Target0
{	
	//llastMotionLayer = tex2D(smpMCur1, texcoord);
	return tex2D(smpGCur1, texcoord);
}
float4 SaveGray2PS(float4 position : SV_Position, float2 texcoord : TEXCOORD/*, out float4 lastMotionLayer : SV_Target1*/) : SV_Target0
{			
	//lastMotionLayer = tex2D(smpMCur2, texcoord);
	return tex2D(smpGCur2, texcoord);
}
float4 SaveGray3PS(float4 position : SV_Position, float2 texcoord : TEXCOORD/*, out float4 lastMotionLayer : SV_Target1*/) : SV_Target0
{		
	//lastMotionLayer = tex2D(smpMCur3, texcoord);
	return tex2D(smpGCur3, texcoord);
}
float4 SaveGray4PS(float4 position : SV_Position, float2 texcoord : TEXCOORD/*, out float4 lastMotionLayer : SV_Target1*/) : SV_Target0
{		
	//lastMotionLayer = tex2D(smpMCur4, texcoord);
	return tex2D(smpGCur4, texcoord);
}
float4 SaveGray5PS(float4 position : SV_Position, float2 texcoord : TEXCOORD/*, out float4 lastMotionLayer : SV_Target1*/) : SV_Target0
{		
	//lastMotionLayer = tex2D(smpMCur5, texcoord);
	return tex2D(smpGCur5, texcoord);
}
float4 SaveGray6PS(float4 position : SV_Position, float2 texcoord : TEXCOORD/*, out float4 lastMotionLayer : SV_Target1*/) : SV_Target0
{		
	//lastMotionLayer = tex2D(smpMCur6, texcoord);
	return tex2D(smpGCur6, texcoord);
}


//Build New Pyramid
float4 DownscaleGray1PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	return tex2D(smpGCur0, texcoord);
}
float4 DownscaleGray2PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	return tex2D(smpGCur1, texcoord);
}
float4 DownscaleGray3PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	return tex2D(smpGCur2, texcoord);
}
float4 DownscaleGray4PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	return tex2D(smpGCur3, texcoord);
}
float4 DownscaleGray5PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	return tex2D(smpGCur4, texcoord);
}
float4 DownscaleGray6PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	return tex2D(smpGCur5, texcoord);
}



#define TEMP_RESET_THRESH (0.01)

//Estimate motion for each Level of the pyramid
float4 MotionEstimation7PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	 
	float4 curMotionEstimation = CalcMotionLayer(texcoord, float2(0, 0), smpGCur7, smpGLast7, 1);
	return curMotionEstimation;

}


float4 MotionEstimation6PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	 
	float4 upscaledLowerLayer = UpscaleMotion(texcoord, smpGCur6, smpGCur7, smpMCur7);

	float4 curMotionEstimation = CalcMotionLayer(texcoord, motionFromGBuffer(upscaledLowerLayer), smpGCur6, smpGLast6, 1);
	return curMotionEstimation;
}


float4 MotionEstimation5PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	float4 upscaledLowerLayer = UpscaleMotion(texcoord, smpGCur5, smpGCur6, smpMCur6);

	float4 curMotionEstimation = CalcMotionLayer(texcoord, motionFromGBuffer(upscaledLowerLayer), smpGCur5, smpGLast5, 1);
	return curMotionEstimation;
}

float4 MotionEstimation4PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{			
	float4 upscaledLowerLayer = UpscaleMotion(texcoord, smpGCur4, smpGCur5, smpMCur5);

	float4 curMotionEstimation = CalcMotionLayer(texcoord, motionFromGBuffer(upscaledLowerLayer), smpGCur4, smpGLast4, 1);
	return curMotionEstimation;
}

float4 MotionEstimation3PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	float4 upscaledLowerLayer = UpscaleMotion(texcoord, smpGCur3, smpGCur4, smpMCur4);	

	float4 curMotionEstimation = CalcMotionLayer(texcoord, motionFromGBuffer(upscaledLowerLayer), smpGCur3, smpGLast3, 1);
	return curMotionEstimation;
}

float4 MotionEstimation2PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	float4 upscaledLowerLayer = UpscaleMotion(texcoord, smpGCur2, smpGCur3, smpMCur3);
	
	float4 curMotionEstimation = CalcMotionLayer(texcoord, motionFromGBuffer(upscaledLowerLayer), smpGCur2, smpGLast2, 1);
	return curMotionEstimation;
}

float4 MotionEstimation1PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	float4 upscaledLowerLayer = UpscaleMotion(texcoord, smpGCur1, smpGCur2, smpMCur2);

	// if (UI_ME_LAYER_MAX > 1)
	// 	return upscaledLowerLayer;

	float4 curMotionEstimation = CalcMotionLayer(texcoord, motionFromGBuffer(upscaledLowerLayer), smpGCur1, smpGLast1, 1);
	return curMotionEstimation;

}

float4 MotionEstimation0PS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{	
	float4 upscaledLowerLayer = UpscaleMotion(texcoord, smpGCur0, smpGCur1, smpMCur1);

	// if (UI_ME_LAYER_MAX > 0)
	// 	return upscaledLowerLayer;
		
	float4 curMotionEstimation = CalcMotionLayer(texcoord, motionFromGBuffer(upscaledLowerLayer), smpGCur0, smpGLast0, 1 + UI_ME_SUB_PIXEL_DETAIL);
	return curMotionEstimation;
}


float2 MotionOutputPS(float4 position : SV_Position, float2 texcoord : TEXCOORD ) : SV_Target
{
	return tex2D(smpMCur0, texcoord).rg;
}



//
float4 OutputPS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{	
	float4 returnValue = 0;

	if (UI_DEBUG_ENABLE)
	{
		returnValue =  motionToLgbtq(tex2D(SamplerMotionVectors, texcoord).rg);
	}
	else
	{
		returnValue = tex2D(ReShade::BackBuffer, texcoord);
	}

	return returnValue;
}


// Technique
technique DRME
{
	//Save Frames
	pass SaveLastColorPass
	{
		VertexShader = PostProcessVS;
		PixelShader = SaveLastPS;
		RenderTarget0 = texCur0;
		RenderTarget1 = texLast0;
		RenderTarget2 = texGLast0;
	}


	pass SaveGray1Pass
	{
		VertexShader = PostProcessVS;
		PixelShader =  SaveGray1PS;
		RenderTarget0 = texGLast1;
	}
	pass SaveGray2Pass
	{
		VertexShader = PostProcessVS;
		PixelShader =  SaveGray2PS;
		RenderTarget0 = texGLast2;
	}
	pass SaveGray3Pass
	{
		VertexShader = PostProcessVS;
		PixelShader =  SaveGray3PS;
		RenderTarget0 = texGLast3;
	}
	pass SaveGray4Pass
	{
		VertexShader = PostProcessVS;
		PixelShader =  SaveGray4PS;
		RenderTarget0 = texGLast4;
	}
	pass SaveGray5Pass
	{
		VertexShader = PostProcessVS;
		PixelShader =  SaveGray5PS;
		RenderTarget0 = texGLast5;
	}
	pass SaveGray6Pass
	{
		VertexShader = PostProcessVS;
		PixelShader =  SaveGray6PS;
		RenderTarget0 = texGLast6;
	}


	//Build gray and motion pyramid
	pass MakeGrayPass
	{
		VertexShader = PostProcessVS;
		PixelShader = CurToGrayPS;
		RenderTarget = texGCur0;
	}


	pass DownscaleGray1Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DownscaleGray1PS;
		RenderTarget = texGCur1;
	}
	pass DownscaleGray2Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DownscaleGray2PS;
		RenderTarget = texGCur2;
	}
	pass DownscaleGray3Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DownscaleGray3PS;
		RenderTarget = texGCur3;
	}
	pass DownscaleGray4Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DownscaleGray4PS;
		RenderTarget = texGCur4;
	}
	pass DownscaleGray5Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DownscaleGray5PS;
		RenderTarget = texGCur5;
	}
	pass DownscaleGray6Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DownscaleGray6PS;
		RenderTarget = texGCur6;
	}


	//Estimate Motion
	/*pass MotionEstimation7Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation7PS;
		RenderTarget = texMotionCur7;
	}*/
	pass MotionEstimation6Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation6PS;
		RenderTarget = texMotionCur6;
	}
	pass MotionEstimation5Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation5PS;
		RenderTarget = texMotionCur5;
	}
	pass MotionEstimation4Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation4PS;
		RenderTarget = texMotionCur4;
	}
	pass MotionEstimation3Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation3PS;
		RenderTarget = texMotionCur3;
	}
	pass MotionEstimation2Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation2PS;
		RenderTarget = texMotionCur2;
	}
	pass MotionEstimation1Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation1PS;
		RenderTarget = texMotionCur1;
	}

	pass MotionEstimation0Pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionEstimation0PS;
		RenderTarget = texMotionCur0;
	}

	pass MotionOutputPass
	{
		VertexShader = PostProcessVS;
		PixelShader = MotionOutputPS;
		RenderTarget = texMotionVectors;
	}

	//Output
	pass OutputPass
	{
		VertexShader = PostProcessVS;
		PixelShader = OutputPS;
	}
}

