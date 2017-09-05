#include <metal_graphics>
#include <metal_texture>
#include <metal_matrix>
#include <metal_common>
using namespace metal;
struct VSConstants
{
float4x4 CC_MVPMatrix;
};
struct VS_INPUT
{
float4 a_position [[attribute(POSITION)]];
float4 a_diffuse [[attribute(DIFFUSE)]];
};
struct PS_INPUT
{
float4 final_position [[position]];
float4 v_texture0;
};
vertex PS_INPUT metal_main(
#ifndef NEOX_METAL_NO_ATTR
VS_INPUT vsIN[[stage_in]],
#endif
constant VSConstants &constants[[buffer(0)]])
{
PS_INPUT psIN;
#ifndef NEOX_METAL_NO_ATTR
psIN.v_texture0 = vsIN.a_diffuse;
float4 local_0 = constants.CC_MVPMatrix * vsIN.a_position;
psIN.final_position = local_0;
#endif
return psIN;
}
