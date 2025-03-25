import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { HealthAssessment, HealthAssessmentSchema } from './health_assessment_schema';
import { HealthAssessmentService } from './health_assessment.service';
import { HealthAssessmentController } from './health_assessment.contoller';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: HealthAssessment.name, schema: HealthAssessmentSchema }]),
  ],
  controllers: [HealthAssessmentController],
  providers: [HealthAssessmentService],
})
export class HealthAssessmentModule {}
