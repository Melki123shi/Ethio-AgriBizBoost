import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class HealthAssessment extends Document {
  @Prop({ required: true })
  cropType: string;

  @Prop({ required: true })
  governmentSubsidy: number;

  @Prop({ required: true })
  salePricePerQuintal: number;

  @Prop({ required: true })
  totalCost: number;

  @Prop({ required: true })
  quantitySold: number;
}

export const HealthAssessmentSchema = SchemaFactory.createForClass(HealthAssessment);
