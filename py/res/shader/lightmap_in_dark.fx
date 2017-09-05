#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define  SHADE_MODE SHADE_PHONG//ֻ��Ϊ�˻�ȡTangent,Binormal

//���Ĭ��ֵ
int GlobalParameter : SasGlobal
<
int3 SasVersion = { 1, 0, 0 };
string SasEffectAuthoring = "hzwangchao2014";
string SasEffectCategory = "";
string SasEffectCompany = "Netease";
string SasEffectDescription = "X9m����ͨ��effect";

NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
NEOX_SASEFFECT_MACRO("lightmap", "LIGHT_MAP_ENABLE", "BOOL", "TRUE")
NEOX_SASEFFECT_MACRO("��Ӱ", "RECEIVE_SHADOW", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("�߹���ͼ", "SPECULAR_MAP_ENABLE", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("������ͼ", "USE_NORMAL_MAP", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("������ͼ", "CUBE_MAP_ENABLE", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("����Ч��", "NEOX_GLASS_ENABLE", "BOOL", "FALSE")
NEOX_SASEFFECT_MACRO("��", "FOG_ENABLE", "BOOL", "FALSE")



//��ͨ������е�  

NEOX_SASEFFECT_SUPPORT_MACRO_END

NEOX_SASEFFECT_ATTR_BEGIN
NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "FALSE")
NEOX_SASEFFECT_ATTR_END
>;


texture	Tex0
<
string SasUiLabel = "��ɫ��ͼ";
string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture = (Tex0);
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipMapLodBias = -0.5f;
};

texture Tex3
<
string SasUiLabel = "SpecularMap";
string SasUiControl = "FilePicker";
>;

sampler SamplerSpecular = sampler_state
{
	Texture = (Tex3);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
};

texture Tex4
<
string SasUiLabel = "NormalMap";
string SasUiControl = "FilePicker";
>;

sampler SamplerNormal = sampler_state
{
	Texture = (Tex4);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
};
texture Tex5
<
string SasUiLabel = "CubeMap";
string SasUiControl = "FilePicker";
>;

sampler	SamplerCube2 = sampler_state
{
	Texture = (Tex5);
	MipFilter = LINEAR;
	//MinFilter =	LINEAR;
	//MagFilter =	LINEAR;
};
texture Tex6
<
string SasUiLabel = "MaskMap";
string SasUiControl = "FilePicker";
>;

sampler SamplerMask = sampler_state
{
	Texture = (Tex6);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
};
float change_color_bright
<
	string SasUiLabel = "�Է���";
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 0.0;
float4 specular_control
<
	string SasUiLabel = "�߹����";
	string SasUiControl = "FloatXPicker";
> = float4(1.0, 1.0, 1.0, 1.0);

float normalmap_factor
<
	string SasUiLabel = "������ͼǿ��"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "2.0";
> = 1.0;

#define SPECULAR_ENABLE FALSE
#define NORMAL_MAP_ENABLE TRUE
#define FOG_TYPE FOG_TYPE_HEIGHT

//����Ӱ���normalmap��Ӧ���ǳ�����ģ���ʱ�����
#define FOG_ENABLE TRUE

//�Զ��岿��
#define CUSTOM_DIFFUSE_MTL
#define CUSTOM_OPACITY
#define CUSTOM_EMISSIVE_MTL



#include "shaderlib/pixellit.tml"
static float view_control = 2.5; //���Ƶ��θ߹������ݷ��߱仯�������Խ��˥��Խ��
static float screen_control = 2.5; //���Ƶ��θ߹�����Ļλ��˥�������Խ�󣬴����Ŀ�ʼ˥��Խ��



bool is_multipy_vector
<
string SasUiLabel = "�Ƿ�˶���ɫ";
string SasUiControl = "ListPicker_BOOL";
> = false;

//ֻ�ں決������ͼ��ʱ��Ѵ˲������ݸ�cloudgi��shader���в�ʹ���������
bool cloudgi_same_direction
<
string SasUiLabel = "ͬ����";
string SasUiControl = "ListPicker_BOOL";
> = false;

float3 GetDiffuseMtl(PS_GENERAL ps_general)
{
	return 0.0;
}

float GetOpacity(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);
	float result = diffuse_map_color.a;
#if NEOX_GLASS_ENABLE
	float3 Normal = ps_general.NormalWorld.xyz;
	float3 V = normalize(CameraPos.xyz - ps_general.PosWorld.xyz);
	float3 NdotV_origin = dot(Normal, V);
	float3 ReflectVector = normalize(2.0 * NdotV_origin * Normal - V);
	float4 env_color = texCUBE(SamplerCube2, ReflectVector);
	result += pow(1 - NdotV_origin, 4.0) * env_color.g * diffuse_map_color.a;
#endif
	return result;
}

float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	float4 diffuse_map_color = tex2D(SamplerDiffuse1, ps_general.TexCoord0.xy);

#if LIGHT_MAP_ENABLE
	float3 lightmap_clr = GetLightMapColor(ps_general);
	diffuse_map_color.rgb *= lightmap_clr;
#endif

	float3 normal = ps_general.NormalWorld;
	float3 light_dir = float3(-0.660, -0.583, 0.474); //DirLightAttr[3].xyz;

#if USE_NORMAL_MAP
	float3 Tangent = ps_general.TangentWorld.xyz;
	float3 Binormal = ps_general.BinormalWorld.xyz;
	float3 normal_offset = float3(0.0, 0.0, 1.0);
	normal_offset.xy = tex2D(SamplerNormal, ps_general.TexCoord0.xy).xy;
	//normal_offset.z = 1 - normal_offset.x - normal_offset.y;
	normal_offset.xy = normal_offset.xy * 2.0 - 1.0;
	normal = normalize(normal_offset.x * Tangent + normal_offset.y * Binormal + normal_offset.z * normal);
	float LdotN_NormalMap = dot(-light_dir, normal.xyz);
	float LdotN_Original = dot(-light_dir, ps_general.NormalWorld.xyz);
	float ratio = 1.0 + (LdotN_NormalMap - LdotN_Original) * normalmap_factor;
	diffuse_map_color.rgb *= ratio;
#endif	

	float3 view_dir = normalize(CameraPos.xyz - ps_general.PosWorld.xyz);
#if CUBE_MAP_ENABLE
	float4 mask_color = tex2D(SamplerMask, ps_general.TexCoord0.xy);
	float3 NdotV_origin = dot(normal, view_dir);
	float3 ReflectVector = normalize(2.0 * NdotV_origin * normal - view_dir);

	float gloss = tex2D(sampleNORMAL, ps_general.TexCoord0.xy).z;
	float4 env_color = texCUBE(SamplerCube2, ReflectVector);
	// env_color.rgb = pow(env_color.rgb, specular_control.g * gloss);
	diffuse_map_color.rgb = lerp(diffuse_map_color.rgb, env_color, mask_color.r);
#endif

	float4 specular_color = float4(0.0, 0.0, 0.0, 0.0);
#if SPECULAR_MAP_ENABLE
	specular_color = tex2D(SamplerSpecular, ps_general.TexCoord0.xy);
	float3 half_vec = normalize(view_dir.xyz - light_dir.xyz);
	float NdotH = saturate(dot(normal, half_vec));
	specular_color.rgb *= pow(NdotH, specular_control.g);
	diffuse_map_color.rgb += specular_color;
#endif
	// float3 result;
	// result += env_color.xyz * mask_color.r + diffuse_map_color.xyz * (1 - mask_color.r);
	// result.rgb = env_color.xyz * specular_control.r * specular_color.rgb * mask_color.r + diffuse_map_color.rgb;//* specular_color.rgb ;//+ diffuse_map_color.rgb;
	return  diffuse_map_color.rgb;
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
		PixelShader = compile ps_3_0 ps_main();
	}
}

