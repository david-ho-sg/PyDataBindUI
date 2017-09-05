////////////////////////////////////////////////////////////////////////////////////////////////////////////
//����:����
//��������:2015.08.25
//����˵��:
//		1.�������Ų�ͬ��ͼ��ͬ��UV�ƶ���ʽ�Ļ����ʵ�ֱ�õı�������Ч��
//		2.ʹ����ͼ��ʵ���ܽ�Ч��,�ܽ������Ҫ�ⲿ������������̬Ч��
//				(1) ��ʹ����Ч�༭����Ӳ�������
//				(2) ���ó����ⲿ���ÿ���
//		3.�ṩ�������������ÿ�������,Ĭ��ȫ���ر�
//				(1) SEC_EMISSIVE_ENABLE �����ڶ��Ŷ�����ͼ
//				(2) DISSOLVE_ENABLE �����ܽ�Ч��
//				(3) RIMLIGHT_ENABLE ������Ե��
//				(4) EMISSIVE_ANIMATION_ENABLE ����������������Ч��
//��һ���޸�:
// �޸�����:2015.10.21
// �޸�����:
//		1.����ò�������������Ч��,��������ʵ������������������Ч����Ŀ��(EMISSIVE_ANIMATION_ENABLE)
//		2.����������ǿ�ȿ���
///////////////////////////////////////////////////////////////////////////////////////////////////////////
#define  NEED_FRAME_TIME
#include "common_defination.fx"
#include "shaderlib/common.fxl"
#define SHADE_MODE SHADE_NONE
//���Ĭ��ֵ
int GlobalParameter : SasGlobal
<
  int3 SasVersion = {1,0,0};
  string SasEffectAuthoring = "hzwangchao2014";
  string SasEffectCategory = "";
  string SasEffectCompany = "Netease";
  string SasEffectDescription = "���ܽ�Ч������������uvEffect";
   
  NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN
  NEOX_SASEFFECT_MACRO("ʹ�õڶ��ŷ���ͼ", "SEC_EMISSIVE_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("ʹ���ܽ�Ч��", "DISSOLVE_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("ʹ�ñ�Ե��", "RIMLIGHT_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("�Է��⶯����������", "EMISSIVE_ANIMATION_ENABLE", "BOOL", "FALSE")
  NEOX_SASEFFECT_MACRO("ʹ�õ��ӵķ�ʽ����ڶ��ŷ�����ͼ", "SEC_EMISSIVE_ADD", "BOOL", "FALSE")
  //��ͨ������е�
  NEOX_SASEFFECT_MACRO("UnSupported", "INSTANCE_TYPE", "UnSupported", "INSTANCE_TYPE_NONE")  
  NEOX_SASEFFECT_MACRO("UnSupported", "LIGHT_MAP_ENABLE", "UnSupported", "FALSE")    
  NEOX_SASEFFECT_MACRO("UnSupported", "SHADOW_MAP_ENABLE", "UnSupported", "FALSE")  
  NEOX_SASEFFECT_SUPPORT_MACRO_END
  
  NEOX_SASEFFECT_ATTR_BEGIN
  NEOX_SASEFFECT_ATTR("INSTANCE_SUPPORTED", "TRUE")
  NEOX_SASEFFECT_ATTR_END
>;
//Variables :
//Textures
//Animation Textures
texture	Tex0
<
	string SasUiLabel = "������ͼ1"; 
	string SasUiControl = "FilePicker";
	
>;
sampler	SamplerEmissive1 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	
	MipMapLodBias = -0.5f;
};
#if SEC_EMISSIVE_ENABLE
texture Tex2
<
	string SasUiLabel = "������ͼ2"; 
	string SasUiControl = "FilePicker"; 
>;
sampler SamplerEmissive2 = sampler_state
{
	Texture	  =	(Tex2);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
};
#endif
#if DISSOLVE_ENABLE
//Dissolve Textures
texture Tex3
<
	string SasUiLabel = "�ܽ���ͼ"; 
	string SasUiControl = "FilePicker"; 
>;

sampler SamplerDissolve3 = sampler_state
{
	Texture	  =	(Tex3);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
};
#endif
texture Tex4
<
	string SasUiLabel = "������ͼ"; 
	string SasUiControl = "FilePicker"; 
	string SamplerAddressU = "ADDRESS_CLAMP";
	string SamplerAddressV = "ADDRESS_CLAMP";
>;

sampler SamplerMask4 = sampler_state
{
	Texture	  =	(Tex4);
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
//Uniform Variables
//Animation Variables
float4 Emissive_color 
<
string SasUiLabel = "��������ɫ"; 
string SasUiControl = "ColorPicker";
>  = float4(1, 1, 1, 0.5);
float4 Emissive_tilling
<
string SasUiLabel = "���������:XY:��һ��Tilling;ZW:�ڶ�Tilling"; 
string SasUiControl = "FloatXPicker";
>  = float4(1, 1, 1, 1);
float4 Emissive_speed
<
string SasUiLabel = "�������ٶȲ���:XY:��һ��UV;ZW:�ڶ�UV"; 
string SasUiControl = "FloatXPicker";
>  = float4(1, 1, 1, 1);
// use 0 - 1 control emissive flow
//�������� ������������UV����
#if EMISSIVE_ANIMATION_ENABLE
float Emissive_animation_ctrl 
<
	string SasUiLabel = "�Է�����������"; 
	string SasUiControl = "FloatPicker";
	string SasUiMin = "0.0";
	string SasUiMax = "1.0";
> = 0.0;
#endif
#if RIMLIGHT_ENABLE
//Rim Variables
float4 Rim_color 
<
string SasUiLabel = "��Ե����ɫ"; 
string SasUiControl = "ColorPicker";
>  = float4(1.0,1.0,1.0, 0.5);
float Rim_pow//diffuse��ͼ����
<
string SasUiLabel = "��Ե�ⷶΧ����"; 
string SasUiControl = "FloatPicker";
string SasUiMin = "0.1";
string SasUiMax = "8.0";
> = 2.0;
#endif
#if DISSOLVE_ENABLE
//Dissolve Variables
float4 Dissolve_color 
<
string SasUiLabel = "�ܽ���ɫ"; 
string SasUiControl = "ColorPicker";
>  = float4(1.0,1.0,1.0, 1);
float Dissolve_intensity
<
string SasUiLabel = "�ܽ�ǿ��"; 
string SasUiControl = "FloatPicker";
string SasUiMin = "-1.0";
string SasUiMax = "1.0";

> = 0.0;
#endif
float4 Shader_Attributes
<
string SasUiLabel = "������ڲ���:XY:DissolveTilling;Z:AnimationSpeed;W:EmissiveIntensity"; 
string SasUiControl = "FloatXPicker";
string SasUiMin = "0.0";
string SasUiMax = "16.0";
> = float4(1.0,1.0,1.0,1.0);

#if DISSOLVE_ENABLE
#define DISSOLVE_TILLTING Shader_Attributes.xy
#endif
#define NORMAL_MAP_ENABLE  FALSE
#define FOG_TYPE FOG_TYPE_HEIGHT

//����Ӱ���normalmap��Ӧ���ǳ�����ģ���ʱ�����
#define FOG_ENABLE TRUE

//�Զ��岿��
#define CUSTOM_OPACITY
#define CUSTOM_EMISSIVE_MTL
#define LIGHT_MAP_ENABLE FALSE 
#define NEED_CAMERA_POS
#define FRAMETIME_SCALE 0.1
#define EMISSIVE_SCALE 4
#include "shaderlib/pixellit.tml"
//////////////////////////////////////////////////////////////////////
//
//	�Է���Ч����ȡ����
//		����Ѷ���Ч���ͱ�Ե�ⶼ��Ϊ�Է���Ч��
//		����Ϊһ��float4���Ͳ���,rgb�洢��Ϻ����ɫ,a�洢��Ϻ��alpha
//			rgb : screen(emissive_color , rimlight_color)
//			a : emissive_color.r + rimlight_color.r
///////////////////////////////////////////////////////////////////////
float4 GetEmissiveColor(PS_GENERAL ps_general){
	float4 result = 0.0;
	float3 emissive_color1;
	float3 emissive_color2;
	//Initialize attributes
	float animation_speed = 0.0;
#if EMISSIVE_ANIMATION_ENABLE
	animation_speed = Emissive_animation_ctrl;
#else
	animation_speed = FrameTime * FRAMETIME_SCALE ;
#endif
	float2 animation_uv1 = ps_general.RawTexCoord0.xy + Emissive_speed.xy * animation_speed;
	animation_uv1 *= Emissive_tilling.xy;
	emissive_color1 = tex2D(SamplerEmissive1,animation_uv1).rgb;
#if SEC_EMISSIVE_ENABLE
	float2 animation_uv2 = ps_general.RawTexCoord0.xy + Emissive_speed.zw * animation_speed;
	animation_uv2 *= Emissive_tilling.zw;
	emissive_color2 = tex2D(SamplerEmissive2,animation_uv2).rgb;
#endif
#if RIMLIGHT_ENABLE
	//
	float3 view_dir = normalize(CameraPos.xyz - ps_general.PosWorld.xyz);
	//Normal parameters
	float3 normal_dir = ps_general.NormalWorld.xyz;
	normal_dir = normalize(normal_dir);
	//Ks
	float NdotV = saturate(dot(normal_dir,view_dir));
#endif

	//Emissive Color
#if SEC_EMISSIVE_ENABLE
#if SEC_EMISSIVE_ADD
	float3 emissive_color = emissive_color1 + emissive_color2;
#else
	float3 emissive_color = min(emissive_color1,emissive_color2);
#endif
#else
	float3 emissive_color = emissive_color1;
#endif

	result.a = emissive_color.r * Shader_Attributes.w;
	emissive_color *= Emissive_color.rgb * Emissive_color.a * EMISSIVE_SCALE * Shader_Attributes.w;
#if RIMLIGHT_ENABLE
	float3 rimlight_color = Rim_color.a * pow(1 - NdotV,Rim_pow)  ;
	result.a += rimlight_color.r;
	rimlight_color *= Rim_color.rgb;
#endif
#if RIMLIGHT_ENABLE
	emissive_color = saturate(1 - (1 - emissive_color) * (1 - rimlight_color));
#else
	emissive_color = emissive_color;
#endif
	result.rgb = emissive_color;
	return result;
}
//////////////////////////////////////////////////////////////////////
//
//	�ܽ�Ч����ȡ����
//		�ܽ�ʹ�ò�����ͼ�ķ�ʽ��ʵ��,��һ�������ͼ����������һ����ͼ��ͨ���ķ�ʽ��ʵ�ֱ�ԵЧ��,
//		��������������ͬ�̶ȵı�Ե����Ե���
//	����float3����Ϊ����rgb��ɫ
///////////////////////////////////////////////////////////////////////
float3 GetDissolveAttribute(PS_GENERAL ps_general){
	float3 dissolve_color = 0.0;
#if DISSOLVE_ENABLE
	//Dissolve
	//ȡ�ܽ�Ч����ͼ
	dissolve_color = tex2D(SamplerDissolve3,ps_general.TexCoord0.xy * DISSOLVE_TILLTING).rgb;
	//��ӿɿ��Ƶ��ܽ�������
	dissolve_color -= Dissolve_intensity ;
	dissolve_color = saturate(dissolve_color);
	//ͨ���ܽ�Ч����ͼ�������ܽ����ͼ,��ȡ���յ��ܽ�״̬,gͨ�������ܽ��Ե����ʽ,bͨ�����Ʊ�Ե��߿��
	float3 dissolve_attribute = tex2D(SamplerMask4,dissolve_color.rg).rgb*2;
	dissolve_attribute = saturate(dissolve_attribute);	
#else
	float3 dissolve_attribute = 0.0;
#endif
	return dissolve_attribute;
}
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
	float3 mask_color = tex2D(SamplerMask4,ps_general.TexCoord0.xy).rgb;
	float4 emissive_color = GetEmissiveColor(ps_general);	
#if DISSOLVE_ENABLE
	float2 dissolve = GetDissolveAttribute(ps_general).gb;	
	result = dissolve.x * emissive_color.a + dissolve.y;
#else
	result =  emissive_color.a;
#endif
	result *= mask_color.r;
	return result;
}
//////////////////////////////////////////////////////////////////////
//
//	�Է��⺯��
//		���Է�����ɫ + �ܽ���ɫ
//	����float3
///////////////////////////////////////////////////////////////////////
float3 GetEmissiveMtl(PS_GENERAL ps_general)
{
	//base attributes
	float3 result = 0.0;
	float3 normal_dir;
	float4 emissive_color = GetEmissiveColor(ps_general);	
#if DISSOLVE_ENABLE
	//Dissolve
	float3 dissolve_attribute = GetDissolveAttribute(ps_general);
	result = emissive_color.rgb *saturate( dissolve_attribute.g - dissolve_attribute.b) +  Dissolve_color.rgb  * Dissolve_color.a * dissolve_attribute.b  ;
#else
	result = emissive_color.rgb;
#endif
	return result;
}

technique TShader
<
	string Description = "���ܽ�Ч������������uvEffect";
>
{
	pass p0
	{	
	//	CullMode = CCW;
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}

