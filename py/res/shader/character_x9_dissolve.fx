#define LIT_ENABLE 0

#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define SHADE_MODE SHADE_PHONG
//���Ĭ��ֵ
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "jwh,hzwangchao2014";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "Ӣ��ͨ�ò���";

  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  NEOX_SASEFFECT_MACRO("�ֲڶ�����", "GLOSS_ENABLE", "BOOL", "TRUE")
  NEOX_SASEFFECT_MACRO("����������", "MENTAL_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("ʹ���ܽ�Ч��", "DISSOLVE_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("ʹ�÷�����ͼ", "NORMAL_MAP_ENABLE", "BOOL", "FALSE")
  
  //��ͨ������е�
  NEOX_SASEFFECT_MACRO("UnSupported", "GPU_SKIN_ENABLE", "UnSupported", "FALSE") 
  NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "TRUE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "FOG_ENABLE", "UnSupported", "FALSE")
  NEOX_SASEFFECT_SUPPORT_MACRO_END
  
  NEOX_SASEFFECT_ATTR_BEGIN
  NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "TRUE")
  NEOX_SASEFFECT_ATTR_END  
>;

#define LIGHT_MAP_ENABLE TRUE

texture	Tex0
<
	string SasUiLabel = "��ɫ��ͼ"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

float matcap_brightness
<
	string SasUiLabel = "������ǿ��"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "8.0";
> = 1;
texture	TexMatcap1
<
	string SasUiLabel = "MatCap"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerMatCap = sampler_state
{
	Texture	  =	(TexMatcap1);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};
float4 ExtraRimColor
<
	string SasUiLabel = "������ɫ";
	string SasUiControl = "ColorPicker";
> = float4(0.0, 0.0, 0.0, 1.0);

#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE TRUE
#define FOG_TYPE FOG_TYPE_HEIGHT

// #define FOG_ENABLE 0
#ifndef FOG_ENABLE
#define FOG_ENABLE FALSE
#endif

#define LIGHT_MAP_ENABLE 0

//�Զ��岿��
//#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_OPACITY
//#define NEED_OPACITY_MTL
#define CUSTOM_EMISSIVE_MTL

#include "shaderlib/pixellit.tml"
const float4 camera_pos:CameraPosition;
#if DISSOLVE_ENABLE
//Dissolve Textures
texture TexDissolve3
<
	string SasUiLabel = "�ܽ���ͼ"; 
	string SasUiControl = "FilePicker"; 
>;
sampler SamplerDissolve3 = sampler_state
{
	Texture	  =	(TexDissolve3);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
//Dissolve Variables
float4 Dissolve_color 
<
	string SasUiLabel = "�ܽ���ɫ"; 
	string SasUiControl = "ColorPicker";
>  = float4(1.0, 1.0, 1.0, 1.0);
float Dissolve_color_intensity
<
	string SasUiLabel = "�ܽ���ɫǿ��"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "10.0";
> = 2.0;
float Dissolve_intensity
<
	string SasUiLabel = "�ܽ�ǿ��"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "-1.0";
	string SasUiMax = "1.0";
> = -0.05;
#endif
#if DISSOLVE_ENABLE
//////////////////////////////////////////////////////////////////////
//
//	�ܽ�Ч����ȡ����
//		�ܽ�ʹ�ò�����ͼ�ķ�ʽ��ʵ��,��һ�������ͼ����������һ����ͼ��ͨ���ķ�ʽ��ʵ�ֱ�ԵЧ��,
//		��������������ͬ�̶ȵı�Ե����Ե���
//	����float3����Ϊ����rgb��ɫ
///////////////////////////////////////////////////////////////////////
float3 GetDissolveAttribute(PS_GENERAL ps_general){
	float3 dissolve_color = 0.0;
	//Dissolve
	//ȡ�ܽ�Ч����ͼ
	dissolve_color = tex2D(SamplerDissolve3,ps_general.TexCoord0.xy).x;
	//��ӿɿ��Ƶ��ܽ�������
	dissolve_color -= Dissolve_intensity ;
	dissolve_color = saturate(dissolve_color);
	//ͨ���ܽ�Ч����ͼ�������ܽ����ͼ,��ȡ���յ��ܽ�״̬,gͨ�������ܽ��Ե����ʽ,bͨ�����Ʊ�Ե��߿��
	float3 dissolve_attribute = tex2D(SamplerDissolve3, dissolve_color.rg).y ;
	dissolve_attribute.g = 1.0f - dissolve_attribute.y;
//	dissolve_attribute = saturate(dissolve_attribute);	
	return dissolve_attribute;
}
#endif
//////////////////////////////////////////////////////////////////////
//
//	͸������
//		���Է���Ч�� * �ܽ�Ч�� * ����ͼ
//	����float
///////////////////////////////////////////////////////////////////////
float GetOpacity(PS_GENERAL ps_general)
{
	//base attributes
	float result = 1.0;
	//Dissolve
	float alpha = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy).a;
#if DISSOLVE_ENABLE
	float dissolve_alpha = GetDissolveAttribute(ps_general).y;	
	result = alpha * dissolve_alpha;
#else
	result = alpha;
#endif
	return result;
}

float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	//vectors
	float3 normal = ps_general.NormalWorld;
	float3 tangent = ps_general.TangentWorld;
	float3 binormal = ps_general.BinormalWorld;
	float3 normal_world = float3(0,0,1);
	float3 normal_view = 0.0;
	float3 view = camera_pos.xyz - ps_general.PosWorld.xyz;
	//K
	//textures
	//diffuse
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);	
	//normal
	float2 normal_offset = tex2D(sampleNORMAL,ps_general.TexCoord0.xy).xy;
	normal_offset = normal_offset * 2.0 - 1.0;
	normal_world.xy = normal_offset ;
	normal_world = normal_world.x * tangent + normal_world.y * binormal + normal_world.z * normal;
	normal_world = normalize(normal_world);
	//matcap
	normal_view = mul(normal_world,(float3x3)ViewMatrix).xyz;
	normal_view.y = -normal_view.y;
	float gloss = tex2D( sampleNORMAL, ps_general.TexCoord0.xy).z;
	normal_view.xy = normal_view.xy * 0.5 + 0.5;
	float3 matcap = 0.0;
#if GLOSS_ENABLE
	float mip = (1 - gloss) * 8 ;
	matcap = tex2Dlod(SamplerMatCap, float4(normal_view.xy, 0, mip)).xyz;
#else
	matcap = 0.0;
#endif
	matcap *= matcap_brightness;
	float3 result = 0;
#if MENTAL_ENABLE
	float mental = 0.0;
	mental = tex2D(sampleNORMAL,ps_general.TexCoord0.xy).w;
	result = diffuse_map_color * (1.0 - mental) + matcap  * diffuse_map_color.rgb * gloss * mental  ;
#else
	result = diffuse_map_color.rgb + matcap * gloss ;
#endif
#if DISSOLVE_ENABLE
	//Dissolve
	float3 dissolve_intensity = GetDissolveAttribute(ps_general).r;
	result = result.rgb + Dissolve_color.rgb * Dissolve_color_intensity * dissolve_intensity;
#endif
	return result;
}

technique TShader
<
	string Description = "Ӣ���ܽ����";
>
{
	pass p0
	{	
	//	CullMode = CCW;
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

