float4x4 wvp;

struct VS_INPUT
{
	float4 Position:	POSITION;
#if GPU_SKIN_ENABLE
	float4 Normal: 		NORMAL;
	float4 BoneWeights: BLENDWEIGHT;
	uint4   BoneIndices: BLENDINDICES;
#endif 
};

struct PS_INPUT
{
	float4 Position:	POSITION;
};

#if GPU_SKIN_ENABLE
float4 BoneVec[MAX_BONES*2];
float3 _DQ_Rot_Vec3(const float4 quat, const float3 v) 
{
    float3 r2,r3;  
    r2 = cross(quat.xyz, v);       //mul+mad 
    r2 = quat.w*v + r2;            //mad 
    r3 = cross(quat.xyz, r2);      //mul+mad 
    r3 = r3 * 2 + v;               //mad 
    return r3;
}

//��Ƥ����
void GetSkin(in float4 bone_weight, in uint4 bone_index, inout float4 position, inout float4 normal)
{
	float3 pos = {0,0,0}, nor = {0,0,0};
	float4 blend_dq[2];
	for (int i = 0; i < 4; ++i)
	{
		if (bone_index[i] < MAX_BONES)
		{
			int sign = 1; // Ҫ������Ԫ���������ԣ���֤����2������ķ���Ϊ��
			if (i > 0 && dot(BoneVec[bone_index[0] * 2], BoneVec[bone_index[i] * 2]) < 0)
			{
				sign = -1;
			}
			
			blend_dq[0] = sign * BoneVec[bone_index[i] * 2 + 0];
			blend_dq[1] = BoneVec[bone_index[i] * 2 + 1];
			
			float3 p, n;
			p = position.xyz * blend_dq[1].w; // ����
			p = _DQ_Rot_Vec3(blend_dq[0], p); // ��ת
			p += blend_dq[1].xyz; // ƽ��
			n = _DQ_Rot_Vec3(blend_dq[0], normal.xyz);
			pos += p * bone_weight[i];
			nor += n * bone_weight[i];
		}
	}

	position.xyz = pos;
	normal.xyz = nor;
}
#endif

//todo����������ֵ�����Ʒ�Χ
PS_INPUT main(VS_INPUT IN)
{
	PS_INPUT OUT = (PS_INPUT)0;

#if GPU_SKIN_ENABLE
	GetSkin(IN.BoneWeights, IN.BoneIndices, IN.Position, IN.Normal);
#endif 
	//��position����normal��������
	OUT.Position = mul(IN.Position , wvp);

	return OUT;
}
