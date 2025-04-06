#include <metal_stdlib>
using namespace metal;

#define PI 3.14159265359
float rnd(float w) {
    return fract(sin(w) * 1000.0);
}

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]], constant float2 *vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID] * 2.0 - 1.0, 0.0, 1.0);
    out.texCoord = vertices[vertexID];
    return out;
}

float slopeFromT (float t, float A, float B, float C){
  float dtdx = 1.0/(3.0*A*t*t + 2.0*B*t + C);
  return dtdx;
}

float xFromT (float t, float A, float B, float C, float D){
  float x = A*(t*t*t) + B*(t*t) + C*t + D;
  return x;
}

float yFromT (float t, float E, float F, float G, float H){
  float y = E*(t*t*t) + F*(t*t) + G*t + H;
  return y;
}

float B0 (float t){
  return (1-t)*(1-t)*(1-t);
}
float B1 (float t){
  return  3*t* (1-t)*(1-t);
}
float B2 (float t){
  return 3*t*t* (1-t);
}
float B3 (float t){
  return t*t*t;
}
float  findx (float t, float x0, float x1, float x2, float x3){
  return x0*B0(t) + x1*B1(t) + x2*B2(t) + x3*B3(t);
}
float  findy (float t, float y0, float y1, float y2, float y3){
  return y0*B0(t) + y1*B1(t) + y2*B2(t) + y3*B3(t);
}

float cubicBezier (float x, float a, float b, float c, float d){

  float y0a = 0.00; // initial y
  float x0a = 0.00; // initial x
  float y1a = b;    // 1st influence y
  float x1a = a;    // 1st influence x
  float y2a = d;    // 2nd influence y
  float x2a = c;    // 2nd influence x
  float y3a = 1.00; // final y
  float x3a = 1.00; // final x

  float A =   x3a - 3*x2a + 3*x1a - x0a;
  float B = 3*x2a - 6*x1a + 3*x0a;
  float C = 3*x1a - 3*x0a;
  float D =   x0a;

  float E =   y3a - 3*y2a + 3*y1a - y0a;
  float F = 3*y2a - 6*y1a + 3*y0a;
  float G = 3*y1a - 3*y0a;
  float H =   y0a;
  
  float currentt = x;
  int nRefinementIterations = 5;
  for (int i=0; i < nRefinementIterations; i++){
    float currentx = xFromT (currentt, A,B,C,D);
    float currentslope = slopeFromT (currentt, A,B,C);
    currentt -= (currentx - x)*(currentslope);
    currentt = clamp(currentt, 0.,1.);
  }

  float y = yFromT (currentt,  E,F,G,H);
  return y;
}

float cubicBezierNearlyThroughTwoPoints(
  float x, float a, float b, float c, float d){

  float y = 0;
  float epsilon = 0.00001;
  float min_param_a = 0.0 + epsilon;
  float max_param_a = 1.0 - epsilon;
  float min_param_b = 0.0 + epsilon;
  float max_param_b = 1.0 - epsilon;
  a = max(min_param_a, min(max_param_a, a));
  b = max(min_param_b, min(max_param_b, b));

  float x0 = 0;
  float y0 = 0;
  float x4 = a;
  float y4 = b;
  float x5 = c;
  float y5 = d;
  float x3 = 1;
  float y3 = 1;
  float x1,y1,x2,y2; // to be solved.

  // arbitrary but reasonable
  // t-values for interior control points
  float t1 = 0.3;
  float t2 = 0.7;

  float B0t1 = B0(t1);
  float B1t1 = B1(t1);
  float B2t1 = B2(t1);
  float B3t1 = B3(t1);
  float B0t2 = B0(t2);
  float B1t2 = B1(t2);
  float B2t2 = B2(t2);
  float B3t2 = B3(t2);

  float ccx = x4 - x0*B0t1 - x3*B3t1;
  float ccy = y4 - y0*B0t1 - y3*B3t1;
  float ffx = x5 - x0*B0t2 - x3*B3t2;
  float ffy = y5 - y0*B0t2 - y3*B3t2;

  x2 = (ccx - (ffx*B1t1)/B1t2) / (B2t1 - (B1t1*B2t2)/B1t2);
  y2 = (ccy - (ffy*B1t1)/B1t2) / (B2t1 - (B1t1*B2t2)/B1t2);
  x1 = (ccx - x2*B2t1) / B1t1;
  y1 = (ccy - y2*B2t1) / B1t1;

  x1 = max(0+epsilon, min(1-epsilon, x1));
  x2 = max(0+epsilon, min(1-epsilon, x2));

  y = cubicBezier (x, x1,y1, x2,y2);
  y = max(0., min(1., y));
  return y;
}

fragment float4 glowShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
  float2 uv = in.texCoord;
  
  for(float i = 1.0; i < 5.0; i++){
    uv.y *= iResolution.y / iResolution.x;
    uv.x += 0.6 / i * cos(i * 2.5* uv.y + time);
    uv.y += 0.6 / i * cos(i * 1.5 * uv.x + time);
  }
  
  float4 color = float4((0.1)/abs(sin(time-uv.y-uv.x)));
  return color;
}

fragment float4 funcGrad(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
  float2 uv = in.texCoord;
 
  float f = cubicBezierNearlyThroughTwoPoints(uv.x, 0.293 + 0.2*cos(10*time/2), 0.667 - 0.3*sin(10*time/7), 0.750 + 0.25*sin(10*time/3), 0.250 - 0.5*cos(10*time/4) + 0.4 - 0.250);

  float3 bottomColor = float3(0.2*uv.x*uv.x + 0.2*sin(10*time*uv.x*uv.y/3 + uv.x), 0.4 *uv.y + uv.x, 0.8 + 0.2*sin(uv.x*10*time));
  float d = 0.2;
  float3 col = 0;
  if (uv.y > f) {
    col = float3(uv.x, uv.y*0.5, sin(10*time));
  }
  if (uv.y < f) {
    col = bottomColor;
  }
  if (abs(f - uv.y) < d) {
    col = mix(bottomColor, col, smoothstep(0, d, abs(f - uv.y)));
  }
  
  float3 targetColor = float3(0.98, 0.92, 0.55);
  col = mix(col,targetColor, 0.8);
  return float4(col, 1);
  }



fragment float4 flow(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;

   float3 col = 1;

  for(float i = 1.0; i < 2.0; i++) {
    uv.y *= iResolution.y / iResolution.x;
    uv.x += 0.6 / i * cos(i * 2.5* uv.y + time);
    uv.y -= 0.6 / i * cos(i * 1.5 * uv.x + time);
  }
  
  float3 color = float3((0.1)/abs(sin(time-uv.y-uv.x)));
   col = mix(color, col, 0.4);
    return float4(col, 1);
}


fragment float4 sinShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
  float2 uv = in.texCoord;
  float3 c = 0;
  float l, z = time;
  for (int i = 0; i<3; i++) {
    float2 p = uv;
    z += 0.5;
    l = length(p);
    uv += p/(l)*(1+ sin(z))*abs(sin(l*9 - z - z));
    c[i] = 0.1 / (length(uv - 0.5*sin(uv.x)));//fmod(uv, 1.0) - 0.5);
  }
  return float4(c/l, time);
  }

float random(float x) {
    return fract(439029.0 * sin(x));
}

float random(float2 uv) {
    return fract(439029.0 * sin(dot(uv, float2(85.3876, 9.38532))));
}

float3 hsv2rgb(float3 c) {
    float3 rgb = clamp(abs(fmod(c.x * 6.0 + float3(0.0, 4.0, 2.0),
                                6.0) - 3.0) - 1.0,
                        0.0,
                        1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return c.z * mix(float3(1.0), rgb, c.y);
}

float regShape(float2 p, int N) {
    float a = atan2(p.y, p.x) + 0.2;
    float b = 6.28319 / float(N);
    return smoothstep(0.5, 0.51, cos(floor(0.5 + a / b) * b - a) * length(p));
}

float3 circle(float2 p, float size, float decay, float3 color, float3 color2, float dist, float2 m) {
    float l = length(p + m * (dist * 4.0)) + size / 2.0;
    float c = max(0.01 - pow(length(p + m * dist), size * 1.4), 0.0) * 50.0;
    float c1 = max(0.001 - pow(l - 0.3, 1.0 / 40.0) + sin(l * 30.0), 0.0) * 3.0;
    float c2 = max(0.04 / pow(length(p - m * dist / 2.0 + 0.09) * 1.0, 1.0), 0.0) / 20.0;
    float s = max(0.01 - pow(regShape(p * 5.0 + m * dist * 5.0 + 0.9, 6), 1.0), 0.0) * 5.0;

    color = 0.5 + 0.5 * sin(color);
    color = cos(float3(0.44, 0.24, 0.2) * 8.0 + dist * 4.0) * 0.5 + 0.5;
    float3 f = c * color;
    f += c1 * color;
    f += c2 * color;
    f += s * color;
    return f - 0.01;
}

float circle(float2 uv, float2 pos, float radius = 0.25) {
  return smoothstep(radius, 0, length(pos - uv));
}

fragment float4 confettiShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 fragCoord = in.texCoord * iResolution;
    float2 uv = (fragCoord - 0.5 * iResolution) / iResolution.y;
    float angle = atan2(-uv.y, -uv.x) + PI;
    float radius = length(uv);
    
    float rayNum = 50.0;
    float rayPadding = 1.0;
    float pulseSize = 0.05;
    float pulseSpeed = 0.7;
    float pulseWarp = 0.3;
    
    /* Drawing rays */
    float sectionSize = 2.0 * PI / rayNum;
    float sectionNum = floor(angle / sectionSize);
    float raySize = 2.0 * PI / (rayNum * (1.0 + rayPadding));
    float rayUv = fmod(angle, sectionSize);
    
    float rays = min(pow((raySize / 2.0) / abs(rayUv - sectionSize / 2.0), 3.0), 1.0);
    
    pulseSpeed += 2.0 * random(sectionNum);
    float pulseIndex = floor((pow(radius, pulseWarp) - 0.3 * pulseSpeed * time*0.5) / pulseSize) * pulseSize;
    float pulses = step(0.85, random(pulseIndex + 0.374 * sectionNum));
    
    rays *= pulses;
    
    /* Coloring */
    float3 HSV;
    HSV[0] = random(pulseIndex);
    HSV[1] = 1.0;
    HSV[2] = rays * min(radius * 12.0, 1.0);
    
    return float4(hsv2rgb(HSV), 1.0);
}

fragment float4 sunShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]], constant float4 &iMagic [[buffer(2)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y;

    float2 mm = iMagic.xy / iResolution.xy - 0.5;
    mm.x *= iResolution.x / iResolution.y;

    if (iMagic.z < 1.0) {
        mm = float2(sin(time / 6.0) / 1.0, cos(time / 8.0) / 2.0) / 2.0;
    }

    float3 circColor = float3(0.9, 0.2, 0.1);
    float3 circColor2 = float3(0.3, 0.1, 0.9);

    float3 color = mix(float3(0.3, 0.2, 0.02) / 0.9, float3(0.2, 0.5, 0.8), uv.y) * 3.0 - 0.52 * sin(time);

    for (float i = 0.0; i < 10.0; i++) {
        color += circle(uv, pow(rnd(i * 2000.0) * 1.8, 2.0) + 1.41, 0.0, circColor + i, circColor2 + i, rnd(i * 20.0) * 3.0 + 0.2 - 0.5, mm);
    }

    float a = atan2(uv.y - mm.y, uv.x - mm.x);
    float bright = 0.1;

    color += max(0.1 / pow(length(uv - mm) * 5.0, 5.0), 0.0) * abs(sin(a * 5.0 + cos(a * 9.0))) / 20.0;
    color += max(0.1 / pow(length(uv - mm) * 10.0, 1.0 / 20.0), 0.0) + abs(sin(a * 3.0 + cos(a * 9.0))) / 8.0 * (abs(sin(a * 9.0))) / 1.0;
    color += (max(bright / pow(length(uv - mm) * 4.0, 1.0 / 2.0), 0.0) * 4.0) * float3(0.2, 0.21, 0.3) * 4.0;
    color *= exp(1.0 - length(uv - mm)) / 5.0;

    return float4(color, 1.0);
}

fragment float4 KinematicShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
  float2 uv = in.texCoord;
//  uv -= 0.5;
//  uv = rotate2D( time*PI*0.4 ) * uv;
//  uv += 0.5;
 // uv = scale(float2(sin(time)+1.0)) * uv;

  float3 color = float3(0)*(1 - exp(-time*0.3));
  float3 bg = float3(uv.x*0.6, uv.y*0.5, abs(sin(time)));
  float3 bg2 = float3(0);
  for(int i = 0; i<10; i++) {
  //  float2 nv = uv;
    float2 ip = float2(fract(sin(float(i)*3009))*0.9, 1);
    float ac = -0.09 - i*0.01;
    float vel = -0.1 + fract(sin(float(i)*5009))*0.5;
    float t1 = sqrt(2/abs(ac));
    int n = int(time/t1);
    float t = time - float(n*t1);
   
    color += circle(uv, float2(ip.x + t*vel, ip.y + ac*t*t/2))*float3(1);
  }
  
  for(int i = 0; i<5; i++) {
    //float2 nv = uv;
    float2 ip = float2(fract(sin(float(i)*3009))*0.9, 0);
    float ac = 0.09 + i*0.01;
    float vel = -0.1 + fract(sin(float(i)*5009))*0.5;
    float t1 = sqrt(2/abs(ac));
    int n = int(time/t1);
    float t = time - float(n*t1);
   
    color += circle(uv, float2(ip.x + t*vel, ip.y + ac*t*t/2))*float3(1);
  }
  
  for(int i = 0; i<5; i++) {

    float2 ip = float2(fract(sin(float(i)*3009))*0.9, 0);
    float ac = 0.09 + i*0.01;
    float vel = -0.1 + fract(sin(float(i)*5009))*0.5;
    float t1 = sqrt(2/abs(ac));
    int n = int(time/t1);
    float t = time - float(n*t1);
   
    color += circle(uv, float2(ip.x + t*vel, ip.y + ac*t*t/2))*float3(1);
  }
  float f = 0.1*exp(-uv.x*2)*cos(time*0.4)*sin(10*uv.x + time)+ 0.6 + 0.2*sin(time);
//  if (uv.y < f) {
    color *= bg;
   // color = yuv2rgb * float3(0.5, nv.x, nv.y);

//  } else {
//    color *= bg;
//    color = mix(bg2, color, smoothstep(0.3, 0, uv.y - f));
//  }
  float2 nv = uv - 0.5;
  nv.y *= iResolution.y/iResolution.x;
  float r = length(nv);
  float fi = atan2(nv.y, nv.x);
  if (r > 0.4) {
    color = mix(float3(0),color, 2/(5*r));
  }
  
  return float4(color, 1);
  }
