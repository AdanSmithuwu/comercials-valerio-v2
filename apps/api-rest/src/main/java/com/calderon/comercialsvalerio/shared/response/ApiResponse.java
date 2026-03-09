package com.calderon.comercialsvalerio.shared.response;
public record ApiResponse <T>(boolean success, String message, T data) {
}