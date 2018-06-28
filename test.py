class Solution:
    def maxArea(self, height):
        """
        :type height: List[int]
        :rtype: int
        """
        ma = 0
        left = 0
        right = len(height) -1
        while left < right:
            ca = min([height[left],height[right]]) * (right - left)
            ma = max([ma,ca])
            if height[left] <= height[right]:
                left = left + 1
            else:
                right = right - 1
        return ma

print(Solution().maxArea([2,3,4,1,5]))
