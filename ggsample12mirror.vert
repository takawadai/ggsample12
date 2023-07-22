#version 410 core

// 光源
layout (std140) uniform Light
{
  vec4 lamb;                                          // 環境光成分
  vec4 ldiff;                                         // 拡散反射光成分
  vec4 lspec;                                         // 鏡面反射光成分
  vec4 lpos;                                          // 位置
};

// 材質
layout (std140) uniform Material
{
  vec4 kamb;                                          // 環境光の反射係数
  vec4 kdiff;                                         // 環境光の反射係数
  vec4 kspec;                                         // 鏡面反射係数
  float kshi;                                         // 輝き係数
};

// 変換行列
uniform mat4 mv;                                      // モデルビュー変換行列
uniform mat4 mp;                                      // 投影変換行列
uniform mat4 mn;                                      // 法線ベクトルの変換行列

// 頂点属性
layout (location = 0) in vec4 pv;                     // ローカル座標系の頂点位置
layout (location = 1) in vec4 nv;                     // 頂点の法線ベクトル

// ラスタライザに送る頂点属性
out vec4 iamb;                                        // 環境光の反射光強度
out vec4 idiff;                                       // 拡散反射光強度
out vec4 ispec;                                       // 鏡面反射光強度

//反射面のベクトル
vec3 mirrorN = vec3(0, 1, 0);
vec3 mirrorP = vec3(0, 0, 0);
vec3 scaling = vec3(1, -1, 1);

void main(void)
{
  vec4 pv2 = vec4(-mirrorP.x + pv.x,  -mirrorP.y + pv.y, -mirrorP.z + pv.z, pv.w);
  vec4 pv3 = vec4(1 * pv2.x, -1 * pv2.y , 1 * pv2.z, pv2.w);
  vec4 pv4 = vec4(mirrorP.x - pv3.x,  mirrorP.y - pv3.y, mirrorP.z - pv3.z, pv3.w);

  //vec4 pv = vec4(pv.x, -pv.y, pv.zw);
  vec4 p = mv * pv;                                   // 視点座標系の頂点の位置
  vec3 v = normalize(p.xyz);                          // 視線ベクトル
  vec3 l = normalize((lpos * p.w - p * lpos.w).xyz);  // 光線ベクトル
  vec3 n = normalize((mn * nv).xyz);                  // 法線ベクトル
  vec3 h = normalize(l - v);                          // 中間ベクトル

  // 陰影計算
  iamb = kamb * lamb;
  idiff = max(dot(-n, l), 0.0) * kdiff * ldiff;
  ispec = pow(max(dot(-n, h), 0.0), kshi) * kspec * lspec;

  // 頂点のスクリーン座標
  gl_Position = mp * p;
}
