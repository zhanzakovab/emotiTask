"""
MBTI Personality Calculator
Maps the 10 fun scenario-based questions to MBTI dimensions and calculates personality type.
"""

from typing import List, Dict, Tuple
from .models import AssessmentAnswer

class MBTICalculator:
    """
    Calculates MBTI personality type based on assessment answers.
    
    The 10 questions map to MBTI dimensions as follows:
    - Questions 1, 2: Extraversion (E) vs Introversion (I)
    - Questions 3, 4, 5: Sensing (S) vs Intuition (N)
    - Questions 6, 7, 8: Thinking (T) vs Feeling (F)
    - Questions 9, 10: Judging (J) vs Perceiving (P)
    """
    
    # Question mapping to MBTI dimensions
    QUESTION_MAPPING = {
        # Extraversion vs Introversion (social energy)
        1: "E_I",  # Free Saturday activity
        2: "E_I",  # House party behavior
        
        # Sensing vs Intuition (information processing)
        3: "S_N",  # Brainstorm participation
        4: "S_N",  # Learning preference
        5: "S_N",  # Reading preference
        
        # Thinking vs Feeling (decision making)
        6: "T_F",  # Work feedback preference
        7: "T_F",  # Advice giving style
        8: "T_F",  # Debate enjoyment
        
        # Judging vs Perceiving (lifestyle)
        9: "J_P",  # Project planning
        10: "J_P", # Weekend planning
    }
    
    # Answer scoring for each question (answer_index -> score)
    # Positive scores lean toward E, N, T, J
    # Negative scores lean toward I, S, F, P
    ANSWER_SCORES = {
        # Question 1: Free Saturday (E/I)
        1: {0: 2, 1: 1, 2: -1, 3: -2},  # Rally friends(E) -> Solo walk(I)
        
        # Question 2: House party (E/I)
        2: {0: 2, 1: 1, 2: -1, 3: -2},  # Introduce to everyone(E) -> Pet/balcony(I)
        
        # Question 3: Brainstorm (S/N)
        3: {0: -2, 1: -1, 2: 1, 3: 2},  # Fire off ideas(S) -> Sketch privately(N)
        
        # Question 4: Learning (S/N)
        4: {0: -2, 1: -1, 2: 1, 3: 2},  # Step-by-step(S) -> Future possibilities(N)
        
        # Question 5: Reading (S/N)
        5: {0: -2, 1: -1, 2: 1, 3: 2},  # Sensory details(S) -> Philosophical themes(N)
        
        # Question 6: Feedback (T/F)
        6: {0: 2, 1: 1, 2: -1, 3: -2},  # Followed playbook(T) -> Redefines vision(F)
        
        # Question 7: Advice (T/F)
        7: {0: 2, 1: 1, 2: -1, 3: -2},  # Cold facts(T) -> Emotional support(F)
        
        # Question 8: Debate (T/F)
        8: {0: 2, 1: 1, 2: -1, 3: -2},  # Logical fallacies(T) -> Mutual understanding(F)
        
        # Question 9: Project planning (J/P)
        9: {0: 2, 1: 1, 2: -1, 3: -2},  # Color-coded timeline(J) -> See vibes tomorrow(P)
        
        # Question 10: Weekend planning (J/P)
        10: {0: 2, 1: 1, 2: -1, 3: -2}, # Map activities(J) -> Random invites(P)
    }
    
    @classmethod
    def calculate_personality_type(cls, answers: List[AssessmentAnswer]) -> Tuple[str, float]:
        """
        Calculate MBTI personality type from assessment answers.
        
        Args:
            answers: List of assessment answers
            
        Returns:
            Tuple of (personality_type, confidence_score)
        """
        # Initialize dimension scores
        dimension_scores = {
            "E_I": 0,  # Positive = E, Negative = I
            "S_N": 0,  # Positive = N, Negative = S
            "T_F": 0,  # Positive = T, Negative = F
            "J_P": 0,  # Positive = J, Negative = P
        }
        
        # Count answers per dimension for confidence calculation
        dimension_counts = {
            "E_I": 0,
            "S_N": 0,
            "T_F": 0,
            "J_P": 0,
        }
        
        # Process each answer
        for answer in answers:
            question_id = answer.question_id
            answer_index = cls._get_answer_index(answer.answer_id, question_id)
            
            if question_id in cls.QUESTION_MAPPING and question_id in cls.ANSWER_SCORES:
                dimension = cls.QUESTION_MAPPING[question_id]
                score = cls.ANSWER_SCORES[question_id].get(answer_index, 0)
                
                dimension_scores[dimension] += score
                dimension_counts[dimension] += 1
        
        # Determine personality type
        personality_type = ""
        personality_type += "E" if dimension_scores["E_I"] > 0 else "I"
        personality_type += "N" if dimension_scores["S_N"] > 0 else "S"
        personality_type += "T" if dimension_scores["T_F"] > 0 else "F"
        personality_type += "J" if dimension_scores["J_P"] > 0 else "P"
        
        # Calculate confidence score
        confidence_score = cls._calculate_confidence(dimension_scores, dimension_counts)
        
        return personality_type, confidence_score
    
    @classmethod
    def _get_answer_index(cls, answer_id: int, question_id: int) -> int:
        """
        Convert answer_id to answer_index (0-3) for scoring.
        Assumes answers are ordered by ID within each question.
        """
        # For questions 1-10, answers should be in groups of 4
        # Question 1: answer_ids 1-4 -> indices 0-3
        # Question 2: answer_ids 5-8 -> indices 0-3
        # etc.
        base_answer_id = (question_id - 1) * 4 + 1
        answer_index = answer_id - base_answer_id
        
        # Ensure answer_index is in valid range
        return max(0, min(3, answer_index))
    
    @classmethod
    def _calculate_confidence(cls, dimension_scores: Dict[str, int], dimension_counts: Dict[str, int]) -> float:
        """
        Calculate confidence score based on how decisive the answers were.
        
        Args:
            dimension_scores: Scores for each MBTI dimension
            dimension_counts: Number of answers for each dimension
            
        Returns:
            Confidence score between 0.5 and 0.95
        """
        total_strength = 0
        total_possible = 0
        
        for dimension, score in dimension_scores.items():
            count = dimension_counts[dimension]
            if count > 0:
                # Maximum possible score for this dimension
                max_possible = count * 2  # Each answer can contribute max 2 points
                
                # Strength is how far from neutral (0) the score is
                strength = abs(score) / max_possible if max_possible > 0 else 0
                total_strength += strength
                total_possible += 1
        
        if total_possible == 0:
            return 0.5  # Minimum confidence
        
        # Average strength across all dimensions
        avg_strength = total_strength / total_possible
        
        # Convert to confidence score (0.5 to 0.95)
        confidence = 0.5 + (avg_strength * 0.45)
        
        return min(0.95, max(0.5, confidence))
    
    @classmethod
    def get_personality_description(cls, personality_type: str) -> str:
        """Get a brief description of the personality type."""
        descriptions = {
            "INTJ": "The Architect - Strategic and imaginative, with a plan for everything.",
            "INTP": "The Thinker - Innovative and curious, love exploring new ideas.",
            "ENTJ": "The Commander - Natural leader who thrives on organizing projects.",
            "ENTP": "The Debater - Quick-witted and creative, excellent at generating solutions.",
            "INFJ": "The Advocate - Insightful and principled, work best with meaningful tasks.",
            "INFP": "The Mediator - Creative and idealistic, prefer flexible environments.",
            "ENFJ": "The Protagonist - Charismatic and inspiring, excel at motivating others.",
            "ENFP": "The Campaigner - Enthusiastic and creative, thrive in dynamic environments.",
            "ISTJ": "The Logistician - Reliable and methodical, prefer structured environments.",
            "ISFJ": "The Protector - Caring and detail-oriented, work best in supportive settings.",
            "ESTJ": "The Executive - Organized and decisive, excel at managing projects.",
            "ESFJ": "The Consul - Warm and cooperative, thrive in collaborative environments.",
            "ISTP": "The Virtuoso - Practical and adaptable, prefer hands-on work.",
            "ISFP": "The Adventurer - Gentle and flexible, work best with personal autonomy.",
            "ESTP": "The Entrepreneur - Energetic and pragmatic, excel in fast-paced environments.",
            "ESFP": "The Entertainer - Spontaneous and enthusiastic, thrive in people-focused situations."
        }
        
        return descriptions.get(personality_type, f"Personality type {personality_type}")

# Example usage and testing
if __name__ == "__main__":
    # Test with sample answers
    test_answers = [
        AssessmentAnswer(question_id=1, answer_id=1),  # Rally friends (E)
        AssessmentAnswer(question_id=2, answer_id=2),  # Small group (mild E)
        AssessmentAnswer(question_id=3, answer_id=3),  # Polished thought (mild N)
        AssessmentAnswer(question_id=4, answer_id=4),  # Future possibilities (N)
        AssessmentAnswer(question_id=5, answer_id=3),  # Hidden symbols (N)
        AssessmentAnswer(question_id=6, answer_id=1),  # Followed playbook (T)
        AssessmentAnswer(question_id=7, answer_id=1),  # Cold facts (T)
        AssessmentAnswer(question_id=8, answer_id=2),  # Stress-test ideas (mild T)
        AssessmentAnswer(question_id=9, answer_id=1),  # Color-coded timeline (J)
        AssessmentAnswer(question_id=10, answer_id=2), # Knock out errands (mild J)
    ]
    
    personality_type, confidence = MBTICalculator.calculate_personality_type(test_answers)
    print(f"Calculated personality type: {personality_type}")
    print(f"Confidence score: {confidence:.2f}")
    print(f"Description: {MBTICalculator.get_personality_description(personality_type)}")
