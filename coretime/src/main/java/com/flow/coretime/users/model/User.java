
package com.flow.coretime.users.model;

import java.time.LocalDate;

import org.springframework.format.annotation.DateTimeFormat;

import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.common.enums.PositionType;
import com.flow.coretime.common.enums.RankType;
import com.flow.coretime.users.validation.PasswordMatches;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
@PasswordMatches
public class User {
    @NotBlank(message = "이름을 입력해주세요.")
    private String name;

    @NotBlank(message = "아이디를 입력해주세요.")
    private String id;

    @NotBlank(message = "비밀번호를 입력해주세요.")
    private String password;

    // confirmPassword는 백엔드 DB 저장 필드가 아니므로 @NotBlank 제외
    // 비밀번호 확인 로직은 UserService나 별도 Validator에서 처리해야 합니다.
    private String confirmPassword;

    @NotBlank(message = "이메일을 입력해주세요.")
    @Email(message = "유효한 이메일 주소를 입력해주세요.") // 이메일 형식 검증 추가
    private String email;

    @NotBlank(message = "전화번호를 입력해주세요.")
    @Pattern(regexp = "^(01[016789])-([0-9]{3,4})-([0-9]{4})$", message = "유효한 전화번호 형식을 입력해주세요 (예: 010-1234-5678)") // 전화번호
                                                                                                                    // 형식
                                                                                                                    // 검증
                                                                                                                    // 추가
    private String tel;

    @NotBlank(message = "직위를 선택해주세요.")
    private RankType rank;

    @NotBlank(message = "부서를 선택해주세요.")
    private DepartmentType department;

    @NotBlank(message = "부서를 선택해주세요.")
    private PositionType position;

    @NotNull(message = "생년월일을 입력해주세요.") // LocalDate는 @NotBlank 대신 @NotNull 사용
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate birth;

    private LocalDate createdAt;
    private LocalDate updatedAt;
    private String role;
    private String profileImagePath;
}
