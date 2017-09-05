#include "common_defination.fx"
#include "shaderlib/common.fxl"

//���Ĭ��ֵ
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "lzb";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "ͨ�õĵ���ͼeffect";
   
  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  
  //��ͨ������е�
  NEOX_SASEFFECT_MACRO("UnSupported", "GPU_SKIN_ENABLE", "UnSupported", "FALSE") 
  NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "TRUE")  
  NEOX_SASEFFECT_SUPPORT_MACRO_END
  
  NEOX_SASEFFECT_ATTR_BEGIN
  NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "TRUE")
  NEOX_SASEFFECT_ATTR_END
>;


texture	Tex0 : DiffuseMap
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
                 
texture	SpecularMap : SpecularMap
<
	string SasUiLabel = "�߹�(r)�Է���(g)"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerSpecular = sampler_state
{
	Texture	  =	(SpecularMap);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -1.0f;
};


#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE FALSE
#define FOG_TYPE FOG_TYPE_HEIGHT

//����Ӱ���normalmap��Ӧ���ǳ�����ģ���ʱ�����
#define FOG_ENABLE TRUE

//�Զ��岿��
#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_OPACITY
#define CUSTOM_EMISSIVE_MTL

#define LIGHT_MAP_ENABLE TRUE
#define AMBIENT_COLOR_ENABLE FALSE

#include "shaderlib/pixellit.tml"

static float view_control = 2.5; //���Ƶ��θ߹������ݷ��߱仯�������Խ��˥��Խ��
static float screen_control = 2.5; //���Ƶ��θ߹�����Ļλ��˥�������Խ�󣬴����Ŀ�ʼ˥��Խ��

bool emissive_mask_enable
<

	string SasUiLabel = "�����Է���"; 
	string SasUiControl = "ListPicker_Bool";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = true;

float emissive_mask_intensity
<
	string SasUiLabel = "�Է�������"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "2.0";
> = 10.0;

float3 GetDiffuseMtl(PS_GENERAL ps_general)
{
	//float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);	
	//return diffuse_map_color.xyz;
	return 0.0;
}

float GetOpacity(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);	
	return diffuse_map_color.a;
}

float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);

#if LIGHT_MAP_ENABLE
	float3 lightmap_clr = GetLightMapColor(ps_general);
	diffuse_map_color.rgb *= lightmap_clr;
#endif

	
	float3  emissive_color= diffuse_map_color.xyz;
	//�Է�����ͼ
	// ��cloudgi��lightmapȥ���Է���
	if(emissive_mask_enable)
	{
		float3 emissive_map_mask = tex2D(SamplerSpecular, ps_general.TexCoord0.xy).xyz;	
		emissive_color += emissive_map_mask * emissive_mask_intensity;
	}
	
	return emissive_color;
}
technique TShader
<
	string Description = "��ͨ������ͼ";
>
{
	pass p0
	{	
	//	CullMode = CCW;
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

