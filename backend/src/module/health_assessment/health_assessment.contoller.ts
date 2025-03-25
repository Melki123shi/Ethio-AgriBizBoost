import { Controller, Post, Body } from '@nestjs/common';
import { HealthAssessmentService } from './health_assessment.service';

@Controller('health-assessment')
export class HealthAssessmentController {
  constructor(private readonly assessmentService: HealthAssessmentService) {}

  @Post()
  async createHealthAssessment(@Body() body: any) {
    const result = await this.assessmentService.createAssessment(body);
    return {
      message: 'Health Assessment saved successfully',
      data: result,
    };
  }
}
