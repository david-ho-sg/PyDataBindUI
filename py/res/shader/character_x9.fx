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
  string SasEffectDescription = "H36��ɫ����";

  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  NEOX_SASEFFECT_MACRO("�߼�Ч��", "HIGH_LEVEL_ENABLE", "BOOL", "TRUE")

  // NEOX_SASEFFECT_MACRO("�Ƿ��Ե��", "RIMLIGHT_ENABLE", "BOOL", "FALSE")
  // NEOX_SASEFFECT_MACRO("�ֲڶ�����", "GLOSS_ENABLE", "BOOL", "TRUE")
  // NEOX_SASEFFECT_MACRO("����������", "MENTAL_ENABLE", "BOOL", "FALSE")
  
  //��ͨ������е�
  NEOX_SASEFFECT_MACRO("UnSupported", "GPU_SKIN_ENABLE", "UnSupported", "FALSE")
  NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "FALSE")
  NEOX_SASEFFECT_MACRO("UnSupported", "EXTRA_ALPHA", "UnSupported", "FALSE")
  NEOX_SASEFFECT_MACRO("UnSupported", "FOG_ENABLE", "UnSupported", "FALSE")
  NEOX_SASEFFECT_SUPPORT_MACRO_END
  
  NEOX_SASEFFECT_ATTR_BEGIN
  NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "TRUE")
  NEOX_SASEFFECT_ATTR_END  
>;

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

float melanism
<
	string SasUiLabel = "�ڻ��̶�";
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 0.0;

sampler	SamplerMatCap = sampler_state
{
	Texture	  =	(TexMatcap1);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

#if HIGH_LEVEL_ENABLE
texture TexRimMatcap2
	<
	string SasUiLabel = "TexRimMatcap2"; 
	string SasUiControl = "FilePicker"; 
	>;

sampler SamplerRimLight = sampler_state
{
	Texture	  =	(TexRimMatcap2);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
};

float rimlight_brightness
	<
	string SasUiLabel = "��Ե������"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "32.0";
	> = 1;

float4 rimlight_color
	<
	string SasUiLabel = "��Ե����ɫ"; 
	string SasUiControl = "ColorPicker";
	>  = float4(1, 1, 1, 0);

#endif

float4 ExtraRimColor
<
	string SasUiLabel = "������ɫ";
	string SasUiControl = "ColorPicker";
> = float4(0.0, 0.0, 0.0, 1.0);

float ExtraAlpha
<
	string SasUiLabel = "ģ��͸����";
	string SasUiControl = "FloatPicker";
> = 1.0;

#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE TRUE
#define FOG_TYPE FOG_TYPE_HEIGHT

#ifndef FOG_ENABLE
#define FOG_ENABLE FALSE
#else
#undef FOG_ENABLE
#define FOG_ENABLE FALSE
#endif

//�Զ��岿��
#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_OPACITY
#define CUSTOM_EMISSIVE_MTL

#include "shaderlib/pixellit.tml"
const float4 camera_pos:CameraPosition;
float3 GetDiffuseMtl(PS_GENERAL ps_general)
{
	
	float3 result = 1;
	return result;
}

float GetOpacity(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);	
	return diffuse_map_color.a;
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
	float4 rim = 0.0;
#if HIGH_LEVEL_ENABLE
	float mip = (1 - gloss) * 8 ;
	matcap = tex2Dlod(SamplerMatCap, float4(normal_view.xy, 0, mip)).xyz;
	//rim
	rim = tex2D(SamplerRimLight, normal_view.xy);
	rim = rim * (rimlight_color * rimlight_brightness);
#endif
	matcap *= matcap_brightness;
	float3 result = 0;

	result = (diffuse_map_color.rgb + matcap * gloss)* (1.0 - melanism) + rim.xyz ;

	float3 ambient = 0.0;
#if HIGH_LEVEL_ENABLE
	ambient = tex2Dlod(SamplerMatCap, float4(normal_view.xy, 0, 8)).xyz;
#endif
	//result.rgb  += ambient.rgb * matcap_brightness * gloss * diffuse_map_color.rgb;
	return result;
}

technique TShader
<
	string Description = "H36��ɫ����";
>
{
	pass p0
	{	
	//	CullMode = CCW;
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

