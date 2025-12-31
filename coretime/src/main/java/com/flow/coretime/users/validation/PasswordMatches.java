
package com.flow.coretime.users.validation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

@Target({ElementType.TYPE, ElementType.ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = PasswordMatchesValidator.class)
@Documented
public @interface PasswordMatches {
    String message() default "비밀번호가 일치하지 않습니다."; // 기본 오류 메시지
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};

    // 추가 필드를 통해 비교할 필드 이름을 지정할 수도 있지만,
    // 여기서는 User 객체 내의 특정 필드명을 가정하고 Validator에서 직접 처리합니다.
}
