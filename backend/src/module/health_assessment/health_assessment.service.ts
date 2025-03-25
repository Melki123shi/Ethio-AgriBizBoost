import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { HealthAssessment } from './health_assessment_schema';

@Injectable()
export class HealthAssessmentService {
  constructor(
    @InjectModel(HealthAssessment.name) private assessmentModel: Model<HealthAssessment>,
  ) {}

  async createAssessment(data: any): Promise<HealthAssessment> {
    const newAssessment = new this.assessmentModel(data);
    return newAssessment.save();
  }
}
