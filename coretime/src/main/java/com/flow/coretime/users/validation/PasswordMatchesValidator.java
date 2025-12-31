
package com.flow.coretime.users.validation;

import com.flow.coretime.users.model.User;


import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class PasswordMatchesValidator implements ConstraintValidator<PasswordMatches, Object> {

    @Override
    public void initialize(PasswordMatches constraintAnnotation) {
        // 초기화 로직 (필요시)
    }

    @Override
    public boolean isValid(Object obj, ConstraintValidatorContext context) {
        // 유효성 검사 대상이 되는 객체를 UserDto 타입으로 캐스팅
        User user = (User) obj; // UserDto 대신 실제 사용하는 DTO/Entity 타입으로 변경

        // 비밀번호와 비밀번호 확인 필드를 비교
        // NullPointerException 방지를 위해 null 체크를 먼저 합니다.
        boolean isValid = user.getPassword() != null && user.getPassword().equals(user.getConfirmPassword());

        // 유효성 검사 실패 시 기본 메시지를 비활성화하고, 특정 필드에 오류 메시지를 추가 (선택 사항)
        if (!isValid) {
            context.disableDefaultConstraintViolation(); // 기본 메시지 비활성화
            context.buildConstraintViolationWithTemplate(context.getDefaultConstraintMessageTemplate())
                   .addPropertyNode("confirmPassword") // confirmPassword 필드에 오류를 연결
                   .addConstraintViolation();
        }

        return isValid;
    }
}
