function J_sine_sph_i = calc_sine_2_jacobian_sphere(x11,x12,x13,x21,x22,x23,x31,x32,x33)
%CALC_SINE_2_JACOBIAN_SPHERE
%    J_SINE_SPH_I = CALC_SINE_2_JACOBIAN_SPHERE(X11,X12,X13,X21,X22,X23,X31,X32,X33)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    10-Mar-2018 21:49:19

t2 = x22.*x33;
t3 = x23.*x31;
t4 = x21.*x32;
t5 = x12.*x33;
t6 = x12.*x23;
t27 = x13.*x22;
t7 = t6-t27;
t8 = t7.*x31;
t9 = x13.*x32;
t29 = x23.*x32;
t10 = t2-t29;
t11 = t10.*x11;
t12 = x11.*x33;
t13 = x11.*x23;
t31 = x13.*x21;
t14 = t13-t31;
t33 = x13.*x31;
t15 = t12-t33;
t16 = t15.*x22;
t34 = x21.*x33;
t17 = t3-t34;
t18 = t17.*x12;
t32 = t14.*x32;
t19 = t16+t18-t32;
t20 = x11.*x32;
t21 = x11.*x22;
t35 = x12.*x21;
t22 = t21-t35;
t23 = t22.*x33;
t24 = x12.*x31;
t37 = x22.*x31;
t25 = t4-t37;
t26 = t25.*x13;
t28 = t5-t9;
t30 = t8+t11-t28.*x21;
t36 = t20-t24;
t38 = t23+t26-t36.*x23;
J_sine_sph_i = reshape([t2-x11.*(t8+t11-x21.*(t5-x13.*x32))-x23.*x32,-t5+t9-t30.*x21,t6-t27-t30.*x31,t3-t19.*x12-x21.*x33,t12-t19.*x22-x13.*x31,-t13+t31-t19.*x32,t4-x13.*(t23+t26-x23.*(t20-x12.*x31))-x22.*x31,-t20+t24-t38.*x23,t21-t35-t38.*x33,0.0,0.0,0.0],[3,4]);