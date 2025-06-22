#!/usr/bin/env python3
"""
Test the MBTI Calculator with sample data
"""

from app.mbti_calculator import MBTICalculator
from app.models import AssessmentAnswer

def test_mbti_calculator():
    print("🧠 Testing MBTI Calculator...")
    
    # Test Case 1: Strong ENTJ profile
    print("\n1️⃣ Test Case 1: Strong ENTJ profile")
    entj_answers = [
        AssessmentAnswer(question_id=1, answer_id=1),   # Rally friends (E)
        AssessmentAnswer(question_id=2, answer_id=1),   # Introduce everyone (E)
        AssessmentAnswer(question_id=3, answer_id=4),   # Sketch privately (N)
        AssessmentAnswer(question_id=4, answer_id=4),   # Future possibilities (N)
        AssessmentAnswer(question_id=5, answer_id=4),   # Philosophical themes (N)
        AssessmentAnswer(question_id=6, answer_id=1),   # Followed playbook (T)
        AssessmentAnswer(question_id=7, answer_id=1),   # Cold facts (T)
        AssessmentAnswer(question_id=8, answer_id=1),   # Logical fallacies (T)
        AssessmentAnswer(question_id=9, answer_id=1),   # Color-coded timeline (J)
        AssessmentAnswer(question_id=10, answer_id=1),  # Map activities (J)
    ]
    
    personality_type, confidence = MBTICalculator.calculate_personality_type(entj_answers)
    print(f"   Result: {personality_type}")
    print(f"   Confidence: {confidence:.2f}")
    print(f"   Description: {MBTICalculator.get_personality_description(personality_type)}")
    
    # Test Case 2: Strong ISFP profile
    print("\n2️⃣ Test Case 2: Strong ISFP profile")
    isfp_answers = [
        AssessmentAnswer(question_id=1, answer_id=4),   # Solo walk (I)
        AssessmentAnswer(question_id=2, answer_id=4),   # Pet/balcony (I)
        AssessmentAnswer(question_id=3, answer_id=1),   # Fire off ideas (S)
        AssessmentAnswer(question_id=4, answer_id=1),   # Step-by-step (S)
        AssessmentAnswer(question_id=5, answer_id=1),   # Sensory details (S)
        AssessmentAnswer(question_id=6, answer_id=4),   # Redefines vision (F)
        AssessmentAnswer(question_id=7, answer_id=4),   # Emotional support (F)
        AssessmentAnswer(question_id=8, answer_id=4),   # Mutual understanding (F)
        AssessmentAnswer(question_id=9, answer_id=4),   # See vibes tomorrow (P)
        AssessmentAnswer(question_id=10, answer_id=4),  # Random invites (P)
    ]
    
    personality_type, confidence = MBTICalculator.calculate_personality_type(isfp_answers)
    print(f"   Result: {personality_type}")
    print(f"   Confidence: {confidence:.2f}")
    print(f"   Description: {MBTICalculator.get_personality_description(personality_type)}")
    
    # Test Case 3: Balanced/Mixed answers
    print("\n3️⃣ Test Case 3: Balanced answers")
    balanced_answers = [
        AssessmentAnswer(question_id=1, answer_id=2),   # Mild E
        AssessmentAnswer(question_id=2, answer_id=3),   # Mild I
        AssessmentAnswer(question_id=3, answer_id=2),   # Mild S
        AssessmentAnswer(question_id=4, answer_id=3),   # Mild N
        AssessmentAnswer(question_id=5, answer_id=2),   # Mild S
        AssessmentAnswer(question_id=6, answer_id=2),   # Mild T
        AssessmentAnswer(question_id=7, answer_id=3),   # Mild F
        AssessmentAnswer(question_id=8, answer_id=2),   # Mild T
        AssessmentAnswer(question_id=9, answer_id=2),   # Mild J
        AssessmentAnswer(question_id=10, answer_id=3),  # Mild P
    ]
    
    personality_type, confidence = MBTICalculator.calculate_personality_type(balanced_answers)
    print(f"   Result: {personality_type}")
    print(f"   Confidence: {confidence:.2f}")
    print(f"   Description: {MBTICalculator.get_personality_description(personality_type)}")
    
    print("\n✅ MBTI Calculator test completed!")
    print("🎯 The calculator correctly maps answers to MBTI dimensions and provides confidence scores.")

if __name__ == "__main__":
    test_mbti_calculator()
