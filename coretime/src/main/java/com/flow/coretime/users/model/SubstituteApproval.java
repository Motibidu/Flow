package com.flow.coretime.users.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SubstituteApproval {
    private Long id;
    private String delegatorId;
    private String substituteId;
    private Date startDate;
    private Date endDate;
    private Date createdAt;
}
