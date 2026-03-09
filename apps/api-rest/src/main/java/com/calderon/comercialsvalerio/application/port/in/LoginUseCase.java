package com.calderon.comercialsvalerio.application.port.in;

import com.calderon.comercialsvalerio.application.dto.LoginRequest;
import com.calderon.comercialsvalerio.application.dto.LoginResponse;

public interface LoginUseCase {
    LoginResponse execute(LoginRequest request);
}